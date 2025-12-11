class GamesController < ApplicationController
  before_action :authenticate_user!

  def index
  @games = Game.where(user: current_user)
  end

  def new
    @game = Game.new
    @games = current_user.games
  end

  def create
    @game = current_user.games.build
    # Default scenario to provide context to the LLM
    @game.scenario = "A mysterious event occurred in a Victorian manor.
    As a medium investigator, you must uncover the truth by exploring rooms,
    questioning suspects, and gathering evidence.
    The victim was found in the entrance hall,
    and all suspects remain in the house."
    # @game.secret_scenario =
    if @game.save
      rooms_init(@game)
      personas_init(@game)
      items_init(@game)
      redirect_to room_path(@game.rooms.find_by!(name: "Hall"))
    else
      render :new, status: :unprocessable_entity
    end
  end
  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    redirect_to games_path
  end

  def confront
    @game = Game.find(params[:id])
    killer_correct = params[:killer] == "Mr. Rook"
    room_correct = params[:room] == "Greenhouse"
    weapon_correct = params[:weapon] == "Kitchen knife"

    unless killer_correct && room_correct && weapon_correct
      redirect_to room_path(@game.rooms.first), notice: "Wrong Accusation"
    end

  end

  def stop
    @game = Game.find(params[:id])
    @game.update(game_params)
  end

  def confrontation
  @game = Game.find(params[:id])
  @rooms = @game.rooms
  @personas = Persona.joins(:room).where(rooms: { game_id: @game.id })
  end
  private

  def game_params
    params.require(:game).permit(:elapsed_time)
  end

  def rooms_init(game)
    rooms_data = [
      { name: "Hall",
        position: 1,
        open: true,
        description:"The imposing entrance hall appears in front of you.
        A grand varnished staircase dominates the room, its steps worn by years of usage.
        Portraits line the walls. The central carpet bears faint marks as if someone had run,
        hesitated… or fled. The air here feels colder than in the rest of the house.
        The cozy ambiance is broken once you notice the cadaver eternally sleeping on the ground
        A serene looking man, Mr.Bishop, is murmuring prayers, near the body, as to call help that's not needed anymore.",
        ai_guideline: "Bishop will give you a little introduction of the context.
        If the player searches under the table he finds the 'Piece of paper'.
        There's also dirty footsteps around the room pointing to the greenhouse.
        If the player examines the body, he'll find out laceration and stabbing traces.",
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
        ai_guideline: "A trapdoor is hidden under the rug - it holds the 'Kitchen knife' (murder weapon).
        If player searches under the carpet, reveal the trapdoor with a code lock, the code is 2129.
        If player enters code 2129, the 'Kitchen knife' is found.
        Otherwise, describe the locked trapdoor without revealing contents.",
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
        ai_guideline: "The victim was killed here - only a pool of blood remains as evidence.
        Mrs. Pawn was locked in by the culprit (a tall shadow).
        The culprit was moving the body out when Pawn entered, so they locked her in.
        Pawn has the 'Revolver' (found in the room). If player asks what Pawn saw,
        she describes a tall shadow that locked her in and gives player the 'Revolver'.",
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
        ai_guideline: "In the furnace are half-burnt papers.
        If player searches the furnace, they find 'Old documents' with 3 names visible: Rook, Bishop, and Cavaleer.
        This is key evidence for establishing the motive.",
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
        ai_guideline: "The desk drawer has a hidden compartment containing the 'Cellar key.",
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
        ai_guideline: "The 'Poison' is hidden in the spices cabinet. If player searches cabinet, they find it.",
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
        Mr. Rook a broad, tall and severe looking figure observes you from the back of the room.",
        ai_guideline: "If the player looks at the wooden beam near the ceiling, the 'Rope' can be found.
        Rook is guilty, he has lost his 'Revolver' during his escape from the Greenhouse so he used the 'Kitchen knife' to finish the murder. ",
        item_found: false,
        before_picture_url: helpers.image_url("rooms/before_attic.png"),
        after_picture_url: helpers.image_url("rooms/after_attic.png"),
      }
    ]
    rooms_data.each { |room| game.rooms.create!(room)}
  end

  def personas_init(game)
    persona_data = [
      { name: "Mrs. Queen",
        description: "Graceful, eloquent, and dangerously observant.
        Her smiles feel perfectly rehearsed; her silence, even more so.
        She moves with a precision that suggests she is always three steps ahead in any conversation.
        Pearls at her neck, gloves spotless, yet a faint tremor in her fingers betrays hidden nerves.
        Rumors cling to her like a perfume; secrets, alliances, and a temper sharp enough to cut long before she raises her voice.",
        ai_guideline: "She seems suspicious. Doesn't really want to help.
        She is innocent.",
        item_given: false,
        room: game.rooms.find_by!(name: "Library")
      },
      { name: "Mrs. Cavaleer",
        description: "Restless energy wrapped in a confident grin.
        She carries herself like someone who thrives on risk—quick to act,
        quicker to improvise. Her boots are muddy, her coat battered,
        suggesting she spends more time outside the rules than within them.
        A scar cuts across her jaw, earned in a story she tells differently every time.
        She protects those she chooses with fierce loyalty,
        but her unpredictable nature leaves everyone wondering whose side she's truly on.",
        ai_guideline: "She was outside, smoking a cigarette.
        She saw a light in the Greenhouse and heard loud voices.
        She heard a slammed door.
        She entered and crossed path with Mr. Bishop in the kitchen.
        She suggested to go and check the Greenhouse. The door was locked.
        They (Mr.Bishop and Mrs. Cavaleer) went to hall and discovered the victim.
        She had a panic attack and went back to the kitchen.
        On the way she found the 'Greenhouse key'
        She called the police.",
        item_given: false,
        room: game.rooms.find_by!(name: "Kitchen")
      },
      { name: "Mrs. Pawn",
        description: "Young, timid, and often ignored; exactly how she prefers it.
        Her posture is small, shoulders tense, eyes fixed on the ground as if afraid to take up space.
        But behind that meek exterior lies a surprising alertness.
        She notices details others overlook, absorbing whispers, gestures, and footsteps.
        People underestimate her, unaware she might hold the missing piece to the truth even if she doesn't realize it herself.",
        ai_guideline: "She was searching the Library for a book when she heard people arguing.
        She couldn't understand the content of the dispute so decided to search for the source of the noise.
        The noise was coming from the Greenhouse so she went and entered.
        A tall silhouette pushed her.
        She grabbed his/her pocket and ripped it.
        A gun fell on the ground and she picked it up.
        When she tried to leave the room the door was locked.",
        item_given: false,
        room: game.rooms.find_by!(name: "Greenhouse")
      },
      { name: "Mr. Rook",
        description: "Tall and solid as a wall and twice as immovable.
        Broad-shouldered, square-jawed, he stands with the stoic discipline of someone used to being a guardian.
        His loyalty is unquestionable—or so he insists.
        But the blankness in his expression feels trained, as if hiding doubts he cannot afford to show.
        He carries a quiet heaviness, the kind that comes from witnessing too much… and speaking too little.",
        ai_guideline: "GUILTY - Mr. Rook is the killer.
        He acts serious and helpful while subtly misdirecting the investigation.
        He lost his 'Revolver' fleeing the Greenhouse.
        He used the 'Kitchen knife' on the victim instead.
        His alibi is that he slept through the whole night.",
        item_given: false,
        room: game.rooms.find_by!(name: "Attic")
      },
      { name: "Mr. Bishop",
        description: "Soft-spoken, with a calm that borders on unsettling.
        His voice is warm, but his gaze sharpens whenever he thinks no one is watching.
        He moves with an almost ritualistic precision, hands always folded, steps always measured.
        Symbols hang from his neck, worn thin from years of handling.
        He speaks of guidance and redemption,
        yet there is something in his smile that suggests he knows exactly where everyone's sins are buried.",
        ai_guideline: "He was in the kitchen having a midnight snack when he heard loud noises.
        He then heard something being dragged on the floor.
        He saw Mr. King entering the study.
        He saw Ms. Cavaleer came to the kitchen, she told him she was outside when she heard noises.
        They (Mr. Bishop and Mrs. Cavaleer) went to the Greenhouse to check.
        The door was locked. They (Mr. Bishop and Mrs. Cavaleer) went to the hall and discovered the victim.
        He stayed to offer the last rites.",
        item_given: false,
        room: game.rooms.find_by!(name: "Hall")
      },
      { name: "Mr. King",
        description: "A tall, imposing man whose presence fills the room long before he speaks.
        His once-upright posture has begun to stoop under the weight of decisions he no longer dares to explain.
        Deep lines carve his face, each one a trace of sleepless nights and unspoken worries.
        His eyes—cold, calculating—measure everything and everyone. There's a quiet tension around him,
        as if he knows more than he will ever admit, and fears far more than he lets show.",
        ai_guideline: "He was in the study and heard a noise.
        He went out of the room, saw nothing and came back in the study.
        He spent a little time working and fell asleep.
        He woke up hearing the cries of Mrs. Cavaleer and Mr. Bishop.
        When he left the room he found the 'Worn out paper' just out the study's door.",
        item_given: false,
        room: game.rooms.find_by!(name: "Study")
      }
    ]
    persona_data.each { |persona| Persona.create!(persona) }
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
        persona: game.personas.find_by!(name: "Mrs. Cavaleer"),
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
      persona: game.personas.find_by!(name: "Mrs. Pawn"),
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
      picture_url: helpers.image_url("items/piece_of_paper.png"),
      found: false
      },
      { name: "Worn out paper",
      description: "A worn out piece of paper, only a number is written on it : '21'",
      persona: game.personas.find_by!(name: "Mr. King"),
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
      { name: "Rope",
      description: "A sturdy rope, the end of it looks newer as if it has been gradually cut over the years.",
      # persona: @game.personas.find_by!(name: ""),
      room: game.rooms.find_by!(name: "Attic"),
      picture_url: helpers.image_url("items/rope.png"),
      found: false
      },
      { name: "Old documents",
      description: "Half-burnt papers retrieved from the furnace. Three names are still visible: Rook, Bishop, and Cavaleer.",
      room: game.rooms.find_by!(name: "Cellar"),
      picture_url: helpers.image_url("items/old_documents.png"),
      found: false
      }
    ]
    item_data.each { |item| game.items.create!(item)}
  end
end
