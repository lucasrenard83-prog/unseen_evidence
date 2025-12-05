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
        .with_instructions(system_prompt)
        .ask(@message.content)

      raw = response.content
      json = JSON.parse(raw)

      # message = json["message"]
      item    = json["item_transferred"]
      extract_found_item_name(item)

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
    @message.game.messages.each do |message|
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
    if @message.persona
      "
      Scenario: #{@message.game.scenario}
      Current Room: #{@message.room.name}
      Room description: #{@message.room.description}
      Room secret description: #{@message.room.ai_guideline}
      Suspect in the room: #{@message.persona.name}
      Suspect Public Description: #{@message.persona.description}
      Suspect Secret Description: #{@message.persona.ai_guideline}
      Room items: #{@message.room.items.pluck(:name).join(', ')}

      #{prompt}"
    else
      "
      Scenario: #{@message.game.scenario}
      Current Room: #{@message.room.name}
      Room description: #{@message.room.description}
      Room secret description: #{@message.room.ai_guideline}
      Room items: #{@message.room.items.pluck(:name).join(', ')}

      #{prompt}"
    end
  end

  def extract_found_item_name(text)
    @item = @message.room.items.find_by(name: text)
    if @item
      @item&.update(found: true)
    end
  end

end
