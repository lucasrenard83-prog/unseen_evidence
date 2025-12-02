class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @message = Message.new(content: params["message"]["content"])
    @message.role = "user"
    @message.game = Game.find(params["game_id"].to_i)
    @message.room = Room.find(params["message"]["room_id"].to_i)
    @message.persona = Persona.find_by(room: @message.room)
    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history
      response = @ruby_llm_chat
        .with_instructions(system_prompt)
        .ask(@message.content)
      @answer = Message.new(content: response.content)
      @answer.role = "assistant"
      @answer.game = @message.game
      @answer.room = @message.room
      @answer.persona = @message.persona
      if @answer.save
        redirect_to room_path(@message.room)
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
    "we are playing cluedo, don't betray me"
  end

end
