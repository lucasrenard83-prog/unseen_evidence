class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    @room = Room.find(params[:id])
    @game = @room.game
    @rooms = @game.rooms.order(:position)
    @message = Message.new
    @personas = Persona.joins(:room).where(rooms: { game_id: @game.id })

    # Only create intro message if this is the first time visiting this room
    if @room.messages.count == 0
      intro_msg = "Entering #{@room.name}. #{@room.description}"
      Message.create(
        role: "assistant",
        content: intro_msg,
        room: @room,
        game: @game,
        persona: Persona.find_by(room: @room)
      )
    end

    # Load messages for this room only
    @messages = @room.messages.order(:created_at)
  end
end
