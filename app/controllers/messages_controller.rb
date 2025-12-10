require "net/http"
require "uri"
require "json"
class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create

    # Setup parameters of the message
    @message = Message.new(content: params["message"]["content"])
    @message.role = "user"
    @message.game = Game.find(params["game_id"].to_i)
    @message.room = Room.find(params["message"]["room_id"].to_i)
    @message.persona = Persona.find_by(room: @message.room)

    # Save message and trigger the answer
    if @message.save
      @ruby_llm_chat = RubyLLM.chat

      # tool set to change room when detected
      @change_room_tool = ChangeRoomTool.new
      @ruby_llm_chat.with_tool(@change_room_tool)

      # tool set to change item status when found >> true
      @find_item_tool = FindItemTool.new
      @ruby_llm_chat.with_tool(@find_item_tool)

      # tool to examine the trapdoor in the Library
      @examine_trapdoor_tool = ExamineTrapdoorTool.new
      @ruby_llm_chat.with_tool(@examine_trapdoor_tool)

      build_conversation_history
      response = @ruby_llm_chat
        .with_instructions(system_prompt)
        .ask(@message.content)

      if @change_room_tool.result
        new_room = @message.game.rooms.find_by(name: @change_room_tool.result)
        if new_room&.open
          redirect_to room_path(new_room), allow_other_host: false
          return
        end
      end

      if @find_item_tool.result
        # Rails.logger.info "=== FIND ITEM TOOL RESULT: #{@find_item_tool.result.inspect} ==="
        extract_found_item_name(@find_item_tool.result)
        # Rails.logger.info "=== @item after extract: #{@item.inspect} ==="
      end

      # Check if trapdoor was examined and player has both code pieces
      # Also check for keywords in case AI doesn't call the tool
      trapdoor_keywords = @message.content.downcase.match?(/trappe|trapdoor|tapis|carpet|rug|sous le|under the/)
      tool_triggered = @examine_trapdoor_tool.result.present?

      if (tool_triggered || trapdoor_keywords) && @message.room.name == "Library"
        @show_code_lock = check_has_both_papers
      end

      raw = response.content
      @message.room.reload

      @answer = Message.new(content: raw)
      @answer.role = "assistant"
      @answer.game = @message.game
      @answer.room = @message.room
      @answer.persona = @message.persona
      if @answer.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to room_path(@message.room) }
        end
      else
        raise
      end
    else
      redirect_to room_path(@message.room)
    end
  end

  def tts
    @game = Game.find(params[:game_id])
    message = Message.find(params[:id])
    audio = generate_tts(message.content)
    if audio
      send_data audio, type: "audio/mpeg", disposition: "inline"
    else
      head :bad_gateway
    end
  end

private

  def generate_tts(text)
    voice_id = ENV["ELEVENLABS_VOICE_ID"]
    api_key = ENV["ELEVENLABS_API_KEY"]

    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri)
    req["xi-api-key"]   = api_key
    req["Content-Type"] = "application/json"
    req["Accept"]       = "audio/mpeg"

    req.body = {
      text: text,
      model_id: "eleven_multilingual_v2", # ou autre modèle
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.8
      }
    }.to_json

    res = http.request(req)
    return res.body if res.is_a?(Net::HTTPSuccess)

    Rails.logger.error "ElevenLabs error: #{res.code} #{res.body}"
    nil
  end

  def build_conversation_history
    # Limite à 15 derniers messages pour réduire le coût et la latence
    # Économie estimée : ~10,000 tokens sur une partie longue (~80% réduction)
    @message.game.messages
      .order(created_at: :desc)
      .limit(15)
      .reverse
      .each do |message|
        @ruby_llm_chat.add_message(message)
      end
  end

  def system_prompt
    # Récupère les items de la room (non trouvés uniquement)
    room_items = @message.room.items.where(found: false).pluck(:name)

    # Récupère les items du persona présent (non trouvés uniquement)
    persona_items = @message.persona&.items&.where(found: false)&.pluck(:name) || []

    # Combine les deux listes
    all_items = (room_items + persona_items).uniq

    # Formate l'affichage pour distinguer les sources
    items_display = if all_items.any?
      room_part = room_items.any? ? "In room: #{room_items.join(', ')}" : ""
      persona_part = persona_items.any? ? "Held by suspect: #{persona_items.join(', ')}" : ""
      [room_part, persona_part].reject(&:empty?).join(' | ')
    else
      'NONE - This room is empty'
    end

    "
     You are a narrator in a murder mystery game. You MUST follow these rules strictly:
    CONTEXT (treat as absolute truth - NEVER invent anything not listed here)
    - Scenario: #{@message.game.scenario.presence || 'Not specified'}
    - Current Room: #{@message.room.name}
    - Room Description: #{@message.room.description}
    - Suspect Present: #{@message.persona&.name || 'NONE - No one is in this room'}
    - Suspect Public Info: #{@message.persona&.description || 'N/A'}
    - Items Available: #{items_display}

    HIDDEN INFO (reveal ONLY when player explicitly searches/investigates/examines closely)
    - Room Secret: #{@message.room.ai_guideline.presence || 'None'}
    - Suspect Secret: #{@message.persona&.ai_guideline.presence || 'None'}
    WARNING: Do NOT mention these secrets unless player performs specific investigative action

    STRICT RULES
    1. NEVER invent rooms, items, suspects, or events not listed above
    2. NEVER reveal hidden info unless player takes specific action to discover it
    3. NEVER confirm or deny who the killer is
    4. If player asks about something not in context, say you don't see/know that
    5. Stay in character - respond as the suspect if player addresses them
    6. Keep responses concise (4-6 sentences max)

    If the player wants to move to another room, use the change_room tool with the room name.
    If the player finds or receives an item, use the find_item tool with the exact item name.
    Do not give two items in the same message, only give them one by one.
    NEVER invent items - only use: #{all_items.join(', ').presence || 'none'}

    SPECIAL: In the Library, if the player searches under the carpet/rug or examines the trapdoor, use the examine_trapdoor tool with action 'examine'. Describe finding a locked trapdoor with a code lock.
    "
  end


  def extract_found_item_name(text)
    @item = @message.room.items.find_by(name: text)
    @item ||= @message.persona&.items&.find_by(name: text)

    if @item
      # set room as searched to switch pictures
      if @item.room
        @item.room.update(item_found: true)
      end
      # set item as found and open doors if a key
      @item&.update(found: true)
      if @item.name == "Cellar key"
        Room.where(name: "Cellar").where(game_id: params["game_id"].to_i)[0].update(open: true)
      elsif @item.name == "Greenhouse key"
        Room.where(name: "Greenhouse").where(game_id: params["game_id"].to_i)[0].update(open: true)
      end
    end
  end

  def params_message
    params.require(:message).permit(:room_id, :content, :game_id, )
  end

  def check_has_both_papers
    game_items = @message.game.items
    worn_out_paper = game_items.find_by(name: "Worn out paper")
    piece_of_paper = game_items.find_by(name: "Piece of paper")

     worn_out_paper&.found? && piece_of_paper&.found?
  end

end
