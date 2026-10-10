# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FleshBurrower do
  include_context "two player game"

  let!(:burrower) { ResolvePermanent("Flesh Burrower", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/2 Insect with deathtouch" do
    expect([burrower.power, burrower.toughness]).to eq([2, 2])
    expect(burrower).to be_deathtouch
  end

  it "gives another creature you control deathtouch when it attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    expect(bears).not_to be_deathtouch

    attack_with(burrower)
    game.tick!

    expect(bears).to be_deathtouch
  end

  it "has no target when it is the only creature" do
    attack_with(burrower)

    expect(game.choices).to be_empty
  end

  it "doesn't trigger when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(game.choices).to be_empty
  end
end
