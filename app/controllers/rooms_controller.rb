class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    @room = Room.find(params[:id])
    @game = @room.game
    @rooms = @game.rooms.order(:position)
    @messages = @game.messages
    @message = Message.new

    # Shows the description of the room when entering if no message
    intro_msg = "Entering #{@room.name} "
    if @room.messages.count == 0
      intro_msg += @room.public_description
    end

    @intro = Message.create(
      role: "assistant",
      content: intro_msg,
      room: @room,
      game: @game,
      persona: Persona.find_by(room: @room)
      )
  end

end
