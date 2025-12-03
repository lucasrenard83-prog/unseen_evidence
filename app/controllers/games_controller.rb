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
      # items_init  # Commented out: items require room_id (NOT NULL)
      redirect_to room_path(@game.rooms.find_by!(name: "Hall"))
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rooms_init
    rooms_data = [
      { name: "Hall",
        position: 1,
        open: true,
        description: "The imposing entrance hall appears in front of you.
        A grand varnished staircase dominates the room, its steps worn by years of usage.
        Portraits line the walls. The central carpet bears faint marks as if someone had run,
        hesitated… or fled. The air here feels colder than in the rest of the house.
        The cozy ambiance is broken once you notice the cadaver eternally sleeping on the ground
        A serene looking man, Mr.Bishop, is murmuring prayers, near the body, as to call help that's not needed anymore",
        AI_guildeline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Library",
        position: 2,
        open: true,
        description: "A faint scent of old paper lingers in the air,
        mixed with a discreet hint of wood polish.
        Shelves climb all the way to the ceiling,
        packed with far too many books for anyone to truly read.
        A green-shaded lamp casts a tired glow over an oak desk where a cup of tea sits cold,
        as if time itself had stopped.The silence is heavy, almost expectant,
        as though the walls are waiting for someone to finally uncover a secret kept far too long.
        You notice a tall silhouette holding a cigarette, her judging eyes locked on you, Mrs.Queen",
        AI_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Greenhouse",
        position: 3,
        open: false,
        description: "Flooded with daylight, yet strangely cold.
        The potted plants, luxuriant sea of greens placid and mute.
        Rain taps rhythmically against the glass panes,
        giving the impression of someone whispering just outside.
        Some plants are lying on the ground their roots exposed, their pots broken.
        A small pool of blood lies still only perturbed by footsteps leading out of the room.
        Mrs Pawn appears so small in this gigantic and empty room, she gets up and reveals her tall stature as well as her panicked face,
        a wave of relief running through her face when she sees you, finally opening the door that was blocking her way out",
        AI_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Cellar",
        position: 4,
        open: false,
        description: "Darkness clings to the damp walls,
        forming a heavy, confined atmosphere, a hint of smoke smell lingers .
        The dirt floor shows irregular small prints.
        Shelves filled with jars line the room under a single exposed bulb
        that flickers with a nervous rhythm.
        In the back of the room a furnace lies dormant.
        A draft from nowhere cuts through the stale air,
        almost as if something had moved here not long ago.",
        AI_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Study",
        position: 5,
        open: true,
        description: "The office is narrow and dim,
        filled with the scent of old paper and lingering tension.
        Files and folders sprawl across the desk, some left half-open.
        Weak light filters through a worned-out window in pale, dusty rays.
        On the wall, a map dotted with pins hangs slightly askew. Near the chair,
        a drawer sits ajar and a pen lies on the floor,
        silent hints that someone was here not long ago… whoever they were.
        Mr.King is here observing the grey sky through the window, he salutes you, his back still facing you.",
        AI_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Kitchen",
        position: 6,
        open: true,
        description: "White tiles and gleaming surfaces—almost too clean.
        On the table rests a fruit bowl.
        The fridge hums, the only steady noise in a room
        where even a misplaced spoon could be a potential clue.
        A faint smell of cold food hangs in the air,
        though nothing here seems to have been prepared recently.
        You stumble upon Mrs.Cavaleer when you open the door, she's playing with a knife,
        her eyes lost in the void as if she was contemplating old memories.
        She finally notices you, unfazed she invites you to enter.",
        AI_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      },
      { name: "Attic",
        position: 7,
        open: true,
        description: "The attic is wide and cluttered,
        smelling of dry wood and forgotten memories.
        Beneath the sloping roof, trunks and boxes pile up,
        some slightly open, revealing fragments of a past no one has spoken of.
        Light seeps through loose tiles in thin dusty beams.
        At the center lies a toppled chair and a circular mark on the floor,
        signs of something that happened here… whatever it was.
        Mr.Rook a broad, tall and severe looking figure observes you from the back of the room.",
        AI_guideline: "...",
        item_found: false,
        before_picture_url: "...",
        after_picture_url: "..."
      }
    ]
    rooms_data.each { |room| @game.rooms.create!(room)}
  end

  def personas_init
    persona_data = [
      { name: "Mrs. Queen",
        description: "Graceful, eloquent, and dangerously observant.
        Her smiles feel perfectly rehearsed; her silence, even more so.
        She moves with a precision that suggests she is always three steps ahead in any conversation.
        Pearls at her neck, gloves spotless, yet a faint tremor in her fingers betrays hidden nerves.
        Rumors cling to her like a perfume; secrets, alliances, and a temper sharp enough to cut long before she raises her voice.",
        ai_guideline: "She will throw off the investigator any chance she has;
        not to hide anything but just to prove her point : a medium is a fraud and could never find a murder culprit.
        she will be an obvious choice but she is innocent ",
        item_given: false,
        room: @game.rooms.find_by!(name: "Library")
      },
      { name: "Mrs. Cavaleer",
        description: "",
        ai_guideline: "...",
        item_given: false,
        room: @game.rooms.find_by!(name: "Kitchen")
      },
      { name: "Mrs. Pawn",
        descritption: "Young, timid, and often ignored; exactly how she prefers it.
        Her posture is small, shoulders tense, eyes fixed on the ground as if afraid to take up space.
        But behind that meek exterior lies a surprising alertness.
        She notices details others overlook, absorbing whispers, gestures, and footsteps.
        People underestimate her, unaware she might hold the missing piece to the truth even if she doesn't realize it herself.",
        ai_guideline: "Stuck in the greenhouse; where the victim was killed; from the beginning.
        She holds a big hint on the real culprit but couldnt reveal it since stuck in the room she doesn't know who it is exactly but know it was a tall person.",
        item_given: false,
        room: @game.rooms.find_by!(name: "Greenhouse")
      },
      { name: "Mr. Rook",
        descritption: "Solid as a wall and twice as immovable.
        Broad-shouldered, square-jawed, he stands with the stoic discipline of someone used to being a guardian.
        His loyalty is unquestionable—or so he insists.
        But the blankness in his expression feels trained, as if hiding doubts he cannot afford to show.
        He carries a quiet heaviness, the kind that comes from witnessing too much… and speaking too little.",
        ai_guideline: "He's guilty.
        He is very serious and 'helps' when he can.
        He will keep on pushing the investigator on wrong paths but stays helpful all throughout the game.",
        item_given: false,
        room: @game.rooms.find_by!(name: "Attic")
      },
      { name: "Mr. Bishop",
        description: "Soft-spoken, with a calm that borders on unsettling.
        His voice is warm, but his gaze sharpens whenever he thinks no one is watching.
        He moves with an almost ritualistic precision, hands always folded, steps always measured.
        Symbols hang from his neck, worn thin from years of handling.
        He speaks of guidance and redemption,
        yet there is something in his smile that suggests he knows exactly where everyone's sins are buried.",
        ai_guideline: "His calm but unsettling behavior places the investigator in a weird position of trust/mistrust constantly redirecting his focus on and off him.",
        item_given: false,
        room: @game.rooms.find_by!(name: "Hall")
      },
      { name: "Mr. King",
        description: "A tall, imposing man whose presence fills the room long before he speaks.
        His once-upright posture has begun to stoop under the weight of decisions he no longer dares to explain.
        Deep lines carve his face, each one a trace of sleepless nights and unspoken worries.
        His eyes—cold, calculating—measure everything and everyone. There's a quiet tension around him,
        as if he knows more than he will ever admit, and fears far more than he lets show.",
        ai_guideline: "At ease constantly his behavior is pushing the investigator to trust him
        (which he/she should) and doesnt hesitate to give any info as long as it's true.
        He will be the biggest help you'll have if you sniff around him long enough",
        item_given: false,
        room: @game.rooms.find_by!(name: "Study")
      }
    ]
    persona_data.each { |persona| Persona.create!(persona)}
  end

  def items_init
    item_data = [
      { name: "cellar key",
        description: "it is the key to the cellar.",
        # room: @game.rooms.find_by!(name: ""),
        # persona: @game.personas.find_by!(name: ""),
        picture_url: "",
        found: false
      },
      { name: "greenhouse key",
        description: "it is the key to the greenhouse.",
        # room: @game.rooms.find_by!(name: ""),
        # persona: @game.personas.find_by!(name: ""),
        picture_url: "",
        found: false
      },
      { name: "kitchen knife",
      description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "revolver",
      description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "poison",
      description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "wrench",
      description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "wine bottle",
      description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      },
      { name: "rope",
      description: "it is the key to the cellar.",
      # room: @game.rooms.find_by!(name: ""),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: "",
      found: false
      }
    ]
    item_data.each { |item| Item.create(item)}
  end
end
