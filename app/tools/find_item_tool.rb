class FindItemTool < RubyLLM::Tool
  attr_accessor :result

  # text sent to AI to let it know the role of the tool
  description "Inform the user he has found an item of the game"

  param :item_name,
    type: :string,
    desc: "The item obtained in the game
      (Cellar key, Greenhouse key, Kitchen knife, Poison, Revolver, Piece of paper, Rope, Old documents, or Worn out paper)"

  def execute(item_name:)
    @result = item_name
    {item_found: item_name}
  end

end
