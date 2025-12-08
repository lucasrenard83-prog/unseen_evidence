class ChangeRoomTool < RubyLLM::Tool
  attr_accessor :result

  # text sent to AI to let it know the role of the tool
  description "Player leaves current room.
  Use when they say: go, walk, head to, leave, exit, move to [room]"

  param :room_name,
    type: :string,
    desc: "The room to move to (Hall, Library, Greenhouse, Cellar, Kitchen, Attic, or Study)"

  def execute(room_name:)
    @result = room_name
    {moved_to: room_name}
  end

end
