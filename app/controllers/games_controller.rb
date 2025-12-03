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

  def index
  @games = Game.where(user: current_user)
  end

  def new
    @game = Game.new
    @games = current_user.games
  end

  def create
    @game = current_user.games.build
    @game.scenario = SCENARIO
    @game.secret_scenario = ""
    if @game.save
      rooms_init(@game)
      personas_init
      items_init(@game)
      redirect_to room_path(@game.rooms.find_by!(name: "Hall"))
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rooms_init(game)
    rooms_data = [
      { name: "Hall",
        position: 1,
        open: true,
        description: "The imposing entrance hall is an old school hall.
        A grand varnished staircase dominates the room, its steps worn by years of footsteps.
        Portraits line the walls. The central carpet bears faint marks as if someone had run,
        hesitated… or fled. The air here feels colder than in the rest of the house.
        The player can search but nothing is hidden",
        ai_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Library",
        position: 2,
        open: true,
        description: "...",
        ai_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Greenhouse",
        position: 3,
        open: false,
        description: "...",
        ai_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Cellar",
        position: 4,
        open: false,
        description: "...",
        ai_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Study",
        position: 5,
        open: true,
        description: "...",
        ai_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Kitchen",
        position: 6,
        open: true,
        description: "...",
        ai_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Attic",
        position: 7,
        open: true,
        description: "...",
        ai_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      }
    ]
    rooms_data.each { |room| game.rooms.create!(room)}
  end

  def personas_init
    persona_data = [
      { name: "Mrs. Queen",
        description: "she is a strong and mysterious woman, but nice deeply",
        ai_guideline: "this suspect has the cellar key, and she gives it easily when you ask for it.
        she did not kill you, although she know that the King did it. But she is reluctant to say it",
        item_given: false,
        room: @game.rooms.find_by!(name: "Library")
      },
      { name: "Mrs. Cavaleer",
        description: "...",
        ai_guideline: "...",
        item_given: false,
        room: @game.rooms.find_by!(name: "Kitchen")
      },
      { name: "Mrs. Pawn",
        description: "...",
        ai_guideline: "...",
        item_given: false,
        room: @game.rooms.find_by!(name: "Greenhouse")
      },
      { name: "Mr. Rook",
        description: "...",
        ai_guideline: "he's guilty",
        item_given: false,
        room: @game.rooms.find_by!(name: "Attic")
      },
      { name: "Mr. Bishop",
        description: "...",
        ai_guideline: "...",
        item_given: false,
        room: @game.rooms.find_by!(name: "Hall")
      },
      { name: "Mr. King",
        description: "...",
        ai_guideline: "...",
        item_given: false,
        room: @game.rooms.find_by!(name: "Study")
      }
    ]
    persona_data.each { |persona| Persona.create(persona)}
  end

  def items_init(game)
    item_data = [
      { name: "cellar key",
        description: "it is the key to the cellar.",
        room: game.rooms.find_by!(name: "Hall"),
        # persona: @game.personas.find_by!(name: ""),
        picture_url: "",
        found: false
      },
      { name: "greenhouse key",
        description: "it is the key to the greenhouse.",
        room: game.rooms.find_by!(name: "Kitchen"),
        # persona: @game.personas.find_by!(name: ""),
        picture_url: "",
        found: false
      },
      { name: "kitchen knife",
      description: "it is the key to the cellar.",
      room: game.rooms.find_by!(name: "Cellar"),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "revolver",
      description: "it is the key to the cellar.",
      room: game.rooms.find_by!(name: "Study"),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "poison",
      description: "it is the key to the cellar.",
      room: game.rooms.find_by!(name: "Library"),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "wrench",
      description: "it is the key to the cellar.",
      room: game.rooms.find_by!(name: "Attic"),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      }
      # { name: "wine bottle",
      # description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # # persona: @game.personas.find_by!(name: ""),
      # picture_url: "",
      # found: false
      # },
      # { name: "rope",
      # description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # # persona: @game.personas.find_by!(name: ""),
      # picture_url: "",
      # found: false
      # }
    ]
    item_data.each { |item| game.items.create!(item)}
  end
end
