# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Agents::ScriptedAgent do
  subject(:agent) { described_class.new(answers: %w[first second third]) }

  it "answers choose_action from the queue, in order" do
    expect(agent.choose_action(nil, %w[cast_spell play_land])).to eq("first")
    expect(agent.choose_action(nil, %w[cast_spell play_land])).to eq("second")
  end

  it "answers any choose_* or resolve_choice call from the same queue" do
    expect(agent.choose_targets(nil, %w[a b])).to eq("first")
    expect(agent.choose_blockers(nil, %w[attacker])).to eq("second")
    expect(agent.resolve_choice(nil, double("choice"))).to eq("third")
  end

  it "raises once the scripted answers run out" do
    agent = described_class.new(answers: ["only"])
    agent.choose_action(nil, [])

    expect { agent.choose_action(nil, []) }.to raise_error(Magic::Agents::ScriptedAgent::OutOfAnswers)
  end
end
