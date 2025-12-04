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
      # items_init  # Commented out: items require room_id (NOT NULL)
      redirect_to room_path(@game.rooms.find_by!(name: "Hall"))
    else
      render :new, status: :unprocessable_entity
    end
  end
  def destroy
    @game = Game.find(params[:id])
  #   @game.rooms.each do |room|
  #   room.personas.destroy_all
  #  end
  #   @rooms = @game.rooms
  #   @messages = @game.messages
  #   @items = @game.items
  #   @rooms.destroy_all
  #   @items.destroy_all
  #   @messages.destroy_all
    @game.destroy
    redirect_to games_path
  end

  def confront
    @game = Game.find(params[:id])

    killer_correct = params[:killer] == "Mr. Rook"
    room_correct = params[:room] == "Greenhouse"
    weapon_correct = params[:weapon] == "Kitchen knife"

    if killer_correct && room_correct && weapon_correct
      redirect_to room_path(@game.rooms.first), notice: "Congratulations"
    else
      redirect_to room_path(@game.rooms.first), notice: "Wrong Accusation"
    end

  end

  private

  def rooms_init(game)
    rooms_data = [
      { name: "Hall",
        position: 1,
        open: true,
        description: "The imposing entrance hall appears in front of you.
        A grand varnished staircase dominates the room, its steps worn by years of usage.
        Portraits line the walls. The central carpet bears faint marks as if someone had run,
        hesitated… or fled. The air here feels colder than in the rest of the house.
        The cozy ambiance is broken once you notice the cadaver eternally sleeping on the ground
        A serene looking man, Mr.Bishop, is murmuring prayers, near the body, as to call help that's not needed anymore.",
        ai_guideline: "Bishop will give you a little introduction of the context.
        There's a piece of paper hidden under the table with part of a code, if the player searches under the table he finds the 'Piece of paper'.
        There's also dirty footsteps around the room pointing to the greenhouse.
        If the player examines the body, he'll find out that the murder weapon is probably a knife.",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/before_hall.png"),
        after_picture_url: helpers.image_url("rooms/after_hall.png"),
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
        You notice a tall silhouette holding a cigarette, her judging eyes locked on you, Mrs.Queen.",
        ai_guideline: "A trapdoor is hidden under the rug, it is locked with a code and holds the murder weapon.
        If the player searches under the carpet the trapdoor will be revealed.
        If the player has the item 'Piece of paper' and 'Worn out paper' he will then access the lock.
        Otherwise describe that a lock with a code is present.
        The player needs to guess the right code to unlock the trapdoor.",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/before_library.png"),
        after_picture_url: helpers.image_url("rooms/after_library.png"),
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
        a wave of relief running through her face when she sees you, finally opening the door that was blocking her way out.",
        ai_guideline: "The victim was killed here but only rest a pool of blood as evidence.
        In the room is Mrs Pawn, she was locked in by the culprit.
        The culprit was taking the body out of the room when Pawn entered so he locked her in.
        Pawn retrieved a revolver. If the player asks if Pawn saw something,
        she will tell you about her encounter with a tall shadow that locked her in and gives you the revolver.",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/greenhouse.png"),

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
        ai_guideline: "In the furnace is located a pile of papers half-burnt,
        if the player searches in the furnace he obtains the 'Old documents'. On it the player can distinguish 3 names : Rook, Bishop and Cavaleer.
        It is the evidence needed to validate the motive for the success of the investigation",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/before_cellar.png"),
        after_picture_url: helpers.image_url("rooms/after_cellar.png"),
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
        ai_guideline: "In the desk, in a drawer there's a hidden compartment, if the player searches in it he will find that it holds the 'Cellar Key'.
        If the player is nice with Mr.King, and asks him if he found something he will be rewarded with the 'Worn out paper'",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/before_study.png"),
        after_picture_url: helpers.image_url("rooms/after_study.png"),
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
        ai_guideline: "A poison vial is hidden in the spices cabinet.If the player searches in the cabinet he will find the 'Poison'.
        Cavaleer is holding the 'Greenhouse key'. If the player wants to obtain it he will have to be a bit pushy.",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/before_kitchen.png"),
        after_picture_url: helpers.image_url("rooms/after_kitchen.png"),
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
        ai_guideline: "If the player looks at the wooden beam, near the ceiling, a rope is hidden.
        Rook is guilty, he has lost his revolver during his escape from the greenhouse so he used the knife to finish the murder. ",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/before_attic.png"),
        after_picture_url: helpers.image_url("rooms/after_attic.png"),
      }
    ]
    rooms_data.each { |room| game.rooms.create!(room)}
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
        description: "Restless energy wrapped in a confident grin.
        She carries herself like someone who thrives on risk—quick to act,
        quicker to improvise. Her boots are muddy, her coat battered,
        suggesting she spends more time outside the rules than within them.
        A scar cuts across her jaw, earned in a story she tells differently every time.
        She protects those she chooses with fierce loyalty,
        but her unpredictable nature leaves everyone wondering whose side she's truly on.",
        ai_guideline: "Ideal culprit by her behavior, she holds nothing of real interest but is very invested in the investigation.
        Her personality, charisma and presence pushes the investigator to 'stay on her case'.",
        item_given: false,
        room: @game.rooms.find_by!(name: "Kitchen")
      },
      { name: "Mrs. Pawn",
        description: "Young, timid, and often ignored; exactly how she prefers it.
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
        description: "Solid as a wall and twice as immovable.
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
        ai_guideline: "At ease constantly his behavior is pushing the player to trust him
        (which he/she should) and doesnt hesitate to give any info as long as it's true.
        He will be the biggest help you'll have if you sniff around him long enough.",
        item_given: false,
        room: @game.rooms.find_by!(name: "Study")
      }
    ]
    persona_data.each { |persona| Persona.create!(persona)}
  end

  def items_init(game)
    item_data = [
      { name: "Cellar key",
        description: "it is the key to the cellar.",
        room: game.rooms.find_by!(name: "Study"),
        # persona: Persona.find_by!(name: ""),
        picture_url: helpers.image_url("items/cellar_key.png"),
        found: false
      },
      { name: "Greenhouse key",
        description: "it is the key to the greenhouse.",
        # room: game.rooms.find_by!(name: "Kitchen"),
        persona: Persona.find_by!(name: "Mrs. Cavaleer"),
        picture_url: helpers.image_url("items/greenhouse_key.png"),
        found: false
      },
      { name: "Kitchen knife",
      description: "An old looking kitchen knife, its handle is worn out by the multiple uses over the time.",
      room: game.rooms.find_by!(name: "Library"),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: helpers.image_url("items/knife.png"),
      found: false
      },
      { name: "Revolver",
      description: "An original piece, well decorated and taken care of.",
      # room: game.rooms.find_by!(name: "Study"),
      persona: Persona.find_by!(name: "Mrs. Pawn"),
      picture_url: helpers.image_url("items/revolver.png"),
      found: false
      },
      { name: "Poison",
      description: "A vial of odd looking liquid, its smell burns the nostrils.",
      room: game.rooms.find_by!(name: "Kitchen"),
      # persona: @game.personas.find_by!(name: ""),
      picture_url: helpers.image_url("items/poison.png"),
      found: false
      },
      { name: "Piece of paper",
      description: " A piece of paper with faded words, you can make out part of a code : '29'",
      room: game.rooms.find_by!(name: "Hall"),
      picture_url: helpers.image_url("items/Piece_of_paper"),
      found: false
      },
      { name: "Worn out paper",
      description: "A worn out piece of paper, only a number is written on it : '21'",
      persona:  Persona.find_by!(name: "Mr. King"),
      picture_url: helpers.image_url("items/worn_out_paper.png"),
      found: false
      },
      # { name: "wrench",
      # description: "An old and rusty wrench, it has certainly seen better days.",
      # room: game.rooms.find_by!(name: "Attic"),
      # # persona: @game.personas.find_by!(name: ""),
      # picture_url: "",
      # found: false
      # },

      # { name: "wine bottle",
      # description: "A nice 'cépage' but it seems broken and some mold covers the hole naturaly sealing it.",
      # # persona: @game.personas.find_by!(name: ""),
      # picture_url: "",
      # found: false
      # },
      { name: "rope",
      description: "A sturdy rope, the end of it looks newer as if it has been gradually cut over the years.",
      # persona: @game.personas.find_by!(name: ""),
      room: game.rooms.find_by!(name: "Attic"),
      picture_url: helpers.image_url("items/rope.png"),
      found: false
      }
    ]
    item_data.each { |item| game.items.create!(item)}
  end
end
