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
        extract_found_item_name(@find_item_tool.result)
      end

      raw = response.content
      # json = JSON.parse(raw)

      # message = json["message"]
      # item    = json["item_transferred"]
      # extract_found_item_name(item)
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

private

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
    # Récupère les items de la room
    room_items = @message.room.items.pluck(:name)

    # Récupère les items du persona présent (si existe)
    persona_items = @message.persona&.items&.pluck(:name) || []

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
    6. Keep responses concise (2-4 sentences max)

    If the player wants to move to another room, use the change_room tool with the room name.
    If the player finds or receives an item, use the find_item tool with the exact item name.
    Do not give two items in the same message, only give them one by one.
    NEVER invent items - only use: #{all_items.join(', ').presence || 'none'}

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

end
