# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MostValuableSlayer do
  include_context "two player game"

  let!(:slayer) { ResolvePermanent("Most Valuable Slayer", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/4 Human Warrior" do
    expect([slayer.power, slayer.toughness]).to eq([2, 4])
  end

  it "gives an attacking creature +1/+0 and first strike when you attack" do
    attack_with(slayer)
    game.resolve_choice!(target: slayer) if game.choices.any?
    game.stack.resolve!
    game.tick!

    expect([slayer.power, slayer.toughness]).to eq([3, 4])
    expect(slayer).to be_first_strike
  end
end
