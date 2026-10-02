# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InspiritedVanguard do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Inspirited Vanguard", owner: p1) }

  def counters = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "endures 2 on entering" do
    game.resolve_choice!
    expect(counters).to eq(2)
  end

  it "endures 2 on attacking, here as a 2/2 Spirit token" do
    game.resolve_choice!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: permanent, target: p2)
    current_turn.attackers_declared!
    game.skip_choice!
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([2, 2])
    expect(counters).to eq(2)
  end
end
