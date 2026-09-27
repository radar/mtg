# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Agents::FirstLegalAgent do
  subject(:agent) { described_class.new }

  it "chooses the first legal action, including a pass" do
    expect(agent.choose_action(nil, %w[cast_spell play_land])).to eq("cast_spell")
    expect(agent.choose_action(nil, [nil, "cast_spell"])).to be_nil
  end

  it "chooses the first count targets" do
    expect(agent.choose_targets(nil, %w[a b c], count: 2)).to eq(%w[a b])
  end

  it "declines every block" do
    expect(agent.choose_blockers(nil, %w[attacker])).to eq({})
  end

  it "chooses the first mana payment offered" do
    expect(agent.choose_mana_payment(nil, { generic: 1 }, [{ green: 1 }, { blue: 1 }])).to eq({ green: 1 })
  end

  it "has no generic answer for a choice" do
    expect { agent.resolve_choice(nil, double("choice")) }.to raise_error(NotImplementedError)
  end
end
