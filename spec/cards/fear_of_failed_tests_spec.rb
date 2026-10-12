# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfFailedTests do
  include_context "two player game"

  let!(:fear) { ResolvePermanent("Fear Of Failed Tests", owner: p1) }

  it "is a 2/7 enchantment creature" do
    expect([fear.power, fear.toughness]).to eq([2, 7])
    expect(fear.type?("Enchantment")).to eq(true)
  end

  it "draws that many cards when it deals combat damage to a player" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(fear, target: p2)
    current_turn.attackers_declared!
    game.settle!
    hand_size = p1.hand.count

    go_to_combat_damage!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 2)
  end
end
