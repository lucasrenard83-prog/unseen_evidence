class GamesController < ApplicationController
  before_action :authenticate_user!

  SCENARIO = "Test"
  SECRET_SCENARIO = "Other Test"

  def new
    @game = Game.new
    @games = current_user.games
  end

  def create
    @game = current_user.games.build
    @game.scenario = SCENARIO
    @game.secret_scenario = SECRET_SCENARIO
    if @game.save
      rooms_init
      redirect_to room_path(@game.rooms.find_by!(name: "Hall"))
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rooms_init
    rooms_data = [
      { name: "Hall", public_description: "The imposing entrance hall stretches out like a silent stage... "},
      { name: "Kitchen", public_description: "The imposing entrance hall stretches out like a silent stage... "}
    ]
    rooms_data.each { |room| @game.rooms.create!(room)}
  end

end
