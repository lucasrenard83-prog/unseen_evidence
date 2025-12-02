class GamesController < ApplicationController
  before_action :authenticate_user!

  SCENARIO = "You are an AI narrator inside an interactive Cluedo-style mystery game.
    The player will ask questions, move between rooms, interview suspects, and look for clues.
    You must always answer in-universe, as if the investigation were real.
    You will receive several types of instructions:
      1.	Game context (scenario, timeline, victim, suspects, weapons, rooms).
      2.	Player actions (moving, inspecting, interrogating, analysing evidence).
      3.	Hidden information that the player should not know unless they discover it.
    Your role is to:
      •	describe scenes and environments,
      •	play the NPCs (suspects, witnesses, etc.),
      •	react to what the player does or says,
      •	reveal clues gradually and consistently,
      •	never reveal the solution unless explicitly instructed.
    Stay immersive, atmospheric, and consistent with the established scenario.
    Ask clarifying questions when needed. "
  def new
    @game = Game.new
    @games = current_user.games
  end

  def create
    @game = current_user.games.build
    @game.scenario = SCENARIO
    @game.secret_scenario = ""
    if @game.save
      rooms_init
      personas_init
      items_init
      redirect_to room_path(@game.rooms.find_by!(name: "Hall"))
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rooms_init
    rooms_data = [
      { name: "Hall",
        public_description: "The imposing entrance hall is an old school hall.
        A grand varnished staircase dominates the room, its steps worn by years of footsteps.
        Portraits line the walls. The central carpet bears faint marks as if someone had run,
        hesitated… or fled. The air here feels colder than in the rest of the house.
        The player can search but nothing is hidden",
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
      { name: "Library",
        public_description: " A faint scent of old paper lingers in the air,
        mixed with a discreet hint of wood polish. Shelves climb all the way to the ceiling,
        packed with far too many books for anyone to truly read. A green-shaded lamp casts a
        tired glow over an oak desk where a cup of tea sits cold, as if time itself had stopped.
        The silence is heavy, almost expectant, as though the walls are waiting for someone to
        finally uncover a secret kept far too long. ",
        open: true,
        position: 3},
      { name: "Cellar",
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
      { name: "Bureau",
        public_description: "Flooded with daylight, yet strangely cold.
        The potted plants, luxuriant sea of greens. Rain taps rhythmically
        against the glass panes, giving the impression of someone whispering just outside.
        A round table is scattered with slightly damp papers and a pen frozen mid-stroke,
        abandoned in a moment of abrupt interruption.",
        open: false,
        position: 6},
      { name: "Greenhouse",
        public_description: "Flooded with daylight, yet strangely cold.
        The potted plants, luxuriant sea of greens. Rain taps rhythmically
        against the glass panes, giving the impression of someone whispering just outside.
        A round table is scattered with slightly damp papers and a pen frozen mid-stroke,
        abandoned in a moment of abrupt interruption.",
        open: false,
        position: 7},
    ]
    rooms_data.each { |room| @game.rooms.create!(room)}
  end

  def personas_init
    persona_data = [
      {
        name: "Queen",
        public_description: "she is a strong and mysterious woman, but nice deeply",
        secret_description: "this suspect has the cellar key, and she gives it easily when you ask for it.
        she did not kill you, although she know that the King did it. But she is reluctant to say it",
        room: @game.rooms.find_by!(name: "Hall")
      },
      {
        name: "King",
        public_description: "hello",
        secret_description: "hello but in secret",
        room: @game.rooms.find_by!(name: "Kitchen")
      },
      {
        name: "Bishop",
        public_description: "hello",
        secret_description: "hello but in secret",
        room: @game.rooms.find_by!(name: "Library")
      },
      {
        name: "Rook",
        public_description: "hello",
        secret_description: "hello but in secret",
        room: @game.rooms.find_by!(name: "Attic")
      },
    ]
    persona_data.each { |persona| Persona.create(persona)}
  end

  def items_init
    item_data = [
      {
        name: "cellar key",
        descritption: "it is the key to the cellar.",
        room: @game.rooms.find_by!(name: "Hall"),
        picture_url: "",
        found: false,
        kind: "key"
     }
    ]
    item_data.each { |item| Item.create(item)}
  end
end
