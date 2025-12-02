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
      { name: "Hall",
        public_description: "The imposing entrance hall stretches out like a silent stage.
        A grand varnished staircase dominates the room, its steps worn by years of footsteps.
        Portraits line the walls, staring down with a stillness that borders on unsettling.
        The central carpet bears faint marks as if someone had run,
        hesitated… or fled. The air here feels colder than in the rest of the house. ",
        open: true,
        position: 1
      },
      { name: "Kitchen",
        public_description: "White tiles and gleaming surfaces—almost too clean.
        On the table rests a fruit bowl.
        The fridge hums, the only steady noise in a room
        where even a misplaced spoon could be a potential clue.
        A faint smell of cold smoke hangs in the air,
        though nothing here seems to have been burned recently. ",
        open: true,
        position: 2},
      { name: "library",
        public_description: " A faint scent of old paper lingers in the air,
        mixed with a discreet hint of wood polish. Shelves climb all the way to the ceiling,
        packed with far too many books for anyone to truly read. A green-shaded lamp casts a
        tired glow over an oak desk where a cup of tea sits cold, as if time itself had stopped.
        The silence is heavy, almost expectant, as though the walls are waiting for someone to
        finally uncover a secret kept far too long. ",
        open: true,
        position: 3},
      { name: "Basement",
        public_description: "Darkness clings to the damp walls,
        forming a heavy, confined atmosphere. The dirt floor shows irregular small prints.
        Shelves filled with jars line the room under a single exposed bulb that flickers
        with a nervous rhythm. A draft from nowhere cuts through the stale air,
        almost as if something had moved here not long ago. ",
        open: false,
        position: 4},
      { name: "Attic",
        public_description: "The attic is wide and cluttered,
        smelling of dry wood and forgotten memories. Beneath the sloping roof,
        trunks and boxes pile up, some slightly open, revealing fragments of a
        past no one has spoken of. Light seeps through loose tiles in thin dusty beams.
        At the center lies a toppled chair and a circular mark on the floor—signs
        of something that happened here… whatever it was. ",
        open: false,
        position: 5},
      { name: "Greenhouse",
        public_description: "Flooded with daylight, yet strangely cold.
        The potted plants, luxuriant sea of greens. Rain taps rhythmically
        against the glass panes, giving the impression of someone whispering just outside.
        A round table is scattered with slightly damp papers and a pen frozen mid-stroke,
        abandoned in a moment of abrupt interruption.",
        open: false,
        position: 6}
    ]
    rooms_data.each { |room| @game.rooms.create!(room)}
  end

end
