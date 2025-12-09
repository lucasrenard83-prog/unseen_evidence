class ExamineTrapdoorTool < RubyLLM::Tool
  attr_accessor :result

  description "Use this when the player examines the trapdoor under the carpet in the Library. This will check if they have both code pieces and show the code lock."

  param :action,
    type: :string,
    desc: "The action: 'examine' when player looks at/examines the trapdoor"

  def execute(action:)
    @result = action
    { trapdoor_examined: true }
  end
end
