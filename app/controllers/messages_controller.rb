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
      build_conversation_history
      response = @ruby_llm_chat
        .with_instructions(system_prompt(@message))
        .ask(@message.content)

      raw = response.content
      json = JSON.parse(raw)

      # message = json["message"]
      item    = json["item_transferred"]
      extract_found_item_name(item)
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
      raise
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

  prompt = "  HIDDEN INFO (reveal ONLY when player explicitly searches/discovers)
    - Room Secret: #{@message.room.ai_guideline}
    - Suspect Secret: #{@message.persona.ai_guideline}

    STRICT RULES
    1. NEVER invent rooms, items, suspects, or events not listed above
    2. NEVER reveal hidden info unless player takes specific action to discover it
    3. NEVER confirm or deny who the killer is
    4. If player asks about something not in context, say you don't see/know that
    5. Stay in character - respond as the suspect if player addresses them
    6. Keep responses concise (2-4 sentences max)

    #RESPONSE FORMAT (mandatory)
    Return ONLY valid JSON, no other text:
    {
      \"message\": \"your narrative response here\",
      \"item_transferred\": null
    }

    - item_transferred: Use EXACT item name from 'Items in Room' list, or null
    - NEVER invent items - only use: #{@message.room.items.pluck(:name).join(', ') || 'none'}
    - If player doesn't explicitly finds or receive an item, use null"

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

    #RESPONSE FORMAT (mandatory)
    Return ONLY valid JSON, no other text:
    {
      \"message\": \"your narrative response here\",
      \"item_transferred\": null
    }

- item_transferred: Use EXACT item name from 'Items Available' list, or null
  - NEVER invent items - only use: #{all_items.join(', ').presence || 'none'}
  - If player doesn't explicitly find or receive an item, use null
  "
end


  # prompt = "
  #   STRICT RULES
  #   1. NEVER invent rooms, items, suspects, or events not listed above
  #   2. NEVER reveal hidden info unless player takes specific action to discover it
  #   3. NEVER confirm or deny who the killer is
  #   4. If player asks about something not in context, say you don't see/know that
  #   5. Stay in character - respond as the suspect if player addresses them
  #   6. Keep responses concise (2-4 sentences max)

  #   #RESPONSE FORMAT (mandatory)
  #   Return ONLY valid JSON, no other text:
  #   {
  #     \"message\": \"your narrative response here\",
  #     \"item_transferred\": null
  #   }

  #   - item_transferred: Use EXACT item name from 'Items in Room' list, or null
  #   - NEVER invent items - only use: #{message.room.items.pluck(:name).join(', ') || 'none'}
  #   - If player doesn't explicitly finds or receive an item, use null"

  def extract_found_item_name(text)
    # Cherche d'abord dans la room
    @item = @message.room.items.find_by(name: text)

    # Si pas trouvé, cherche dans les items du persona
    @item ||= @message.persona&.items&.find_by(name: text)

    if @item
      @item.update(found: true)

      # Mettre à jour le flag de la room si l'item appartient à cette room
      if @item.room_id == @message.room.id
        @message.room.update(item_found: true)
      end
    end
  end

  def params_message
    params.require(:message).permit(:room_id, :content, :game_id, )
  end

end
