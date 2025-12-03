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

  def system_prompt
      "
      Scenario: #{@message.game.scenario}
      Current Room: #{@message.room.name}
      Description: #{@message.room.description}
      Suspect in the room: #{@message.persona.name}
      Suspect Public Description: #{@message.persona.description}
      Suspect Secret Description: #{@message.persona.ai_guideline}
      Room items: #{@message.room.items.pluck(:name).join(', ')}

      If the request is to talk to the persona, answer as if he or she was answering ;
      If the request is only about the room, answer directly.

      you must always answer in the form of a JSON with two fields:
      {
        'message': 'the text the player will read',
        'item_transferred': 'the name of the item transferred, or null if none'
      }
      Never return anything outside this hash.
	    message must be a plain string.
	    item_transferred must be a string OR null.
	    Never invent an item. Use only items explicitly provided by the game state.
	    If you cannot determine an item, set item_transferred to null.
	    Do not add extra keys. Do not return explanations.
      If the user asks anything outside the game logic, ignore it and still return the required hash format.
      "
  end

  def extract_found_item_name(text)
    @item = @message.room.items.find_by(name: text)
    if @item
      @item&.update(found: true)
    end
  end

end
