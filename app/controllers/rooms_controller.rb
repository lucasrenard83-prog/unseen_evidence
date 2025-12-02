class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    @room = Room.find(params[:id])
    @game = @room.game
    @rooms = @game.rooms
  end

end
