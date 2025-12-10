class RoomsController < ApplicationController
  before_action :authenticate_user!

  def show
    @room = Room.find(params[:id])
    @game = @room.game
    @rooms = @game.rooms.order(:position)
    @message = Message.new
    @personas = Persona.joins(:room).where(rooms: { game_id: @game.id })

    # Only create intro message if this is the first time visiting this room
    if @game.messages.count == 0
      intro_msg = "A mysterious event occurred in a Victorian manor.
      As a medium and investigator, you must uncover the truth by exploring rooms,
      questioning suspects, and gathering evidence.
      The victim was found in the entrance hall,
      and all suspects remain in the house."
       Message.create(
        role: "assistant",
        content: intro_msg,
        room: @room,
        game: @game,
        persona: Persona.find_by(room: @room)
      )
      intro_msg = "Entering the #{@room.name}.<br> #{@room.description}"
      Message.create(
        role: "assistant",
        content: intro_msg,
        room: @room,
        game: @game,
        persona: Persona.find_by(room: @room)
      )

    elsif @room.messages.count == 0
      intro_msg = "Entering the #{@room.name}.<br> #{@room.description}"
      Message.create(
        role: "assistant",
        content: intro_msg,
        room: @room,
        game: @game,
        persona: Persona.find_by(room: @room)
      )

    else
      last_game_message = @game.messages.order(:created_at).last
      unless last_game_message.room_id == @room.id
        Message.create(
        role: "assistant",
        content: "Entering the #{@room.name}.",
        room: @room,
        game: @game,
        persona: Persona.find_by(room: @room)
      )
      end
    end

    # Load messages for this room only
    @messages = @room.messages.order(:created_at)
  end

  def unlock_trapdoor
    @room = Room.find(params[:id])
    @game = @room.game

    # Find and mark Kitchen knife as found
    kitchen_knife = @game.items.find_by(name: "Kitchen knife")
    if kitchen_knife
      kitchen_knife.update(found: true)
      @room.update(item_found: true)

      # Add a message to the chat
      Message.create(
        role: "assistant",
        content: "The trapdoor opens with a click! Inside, you find a Kitchen knife",
        room: @room,
        game: @game,
        persona: Persona.find_by(room: @room)
      )

      render json: { success: true, item: kitchen_knife.name }
    else
      render json: { success: false, error: "Item not found" }, status: :not_found
    end
  end
end
