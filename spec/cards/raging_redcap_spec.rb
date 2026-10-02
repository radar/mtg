# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RagingRedcap do
  include_context "two player game"

  let!(:redcap) { ResolvePermanent("Raging Redcap", owner: p1) }

  it "is a 1/2 Goblin Knight with double strike" do
    expect([redcap.power, redcap.toughness]).to eq([1, 2])
    expect(redcap).to be_double_strike
  end

  it "deals combat damage twice to a player" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(redcap, target: p2)
    current_turn.attackers_declared!
    current_turn.combat_damage!
    game.settle!

    expect(p2.life).to eq(18)
  end
end
