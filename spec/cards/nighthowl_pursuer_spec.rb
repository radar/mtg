# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NighthowlPursuer do
  include_context "two player game"

  let!(:wolf) { ResolvePermanent("Nighthowl Pursuer", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 1/1 Wolf with menace" do
    expect([wolf.power, wolf.toughness]).to eq([1, 1])
    expect(wolf).to be_menace
  end

  it "gets +2/+2 when it attacks while you control a creature with power 4 or greater" do
    ResolvePermanent("Ordinary Bear", owner: p1)
    attack_with(wolf)

    expect([wolf.power, wolf.toughness]).to eq([3, 3])
  end

  it "doesn't get the bonus without a creature with power 4 or greater" do
    attack_with(wolf)

    expect([wolf.power, wolf.toughness]).to eq([1, 1])
  end
end
