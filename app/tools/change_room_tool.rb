class ChangeRoomTool < RubyLLM::Tool
  attr_accessor :result

  # text sent to AI to let it know the role of the tool
  description "Moves the player to another room in the manor"

  param :room_name,
    type: :string,
    desc: "The room to move to (Hall, Library, Greenhouse, Cellar, Kitchen, Attic, or Study)"

  def execute(room_name:)
    @result = room_name
    {moved_to: room_name}
  end

end
