# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StoneGiantOfHighPass do
  include_context "two player game"

  let!(:giant) { ResolvePermanent("Stone Giant Of High Pass", owner: p1) }

  def boulders = p1.creatures.select { _1.name == "Stone Boulder" }

  it "is a 7/7 Giant" do
    expect([giant.power, giant.toughness]).to eq([7, 7])
  end

  it "creates a 3/1 Wall artifact creature token with defender when it enters" do
    expect(boulders.count).to eq(1)
    boulder = boulders.first
    expect([boulder.power, boulder.toughness]).to eq([3, 1])
    expect(boulder).to be_artifact
    expect(boulder.type?("Wall")).to be(true)
    expect(boulder).to have_keyword(:defender)
    expect(boulder).to be_token
  end

  it "creates another when it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(giant, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(boulders.count).to eq(2)
  end

  it "deals 4 damage to any target for {2}{R} and sacrificing an artifact" do
    boulder = boulders.first
    p1.add_mana(red: 3)
    p1.activate_ability(ability: giant.activated_abilities.first) do |action|
      action.pay_mana(generic: { red: 2 }, red: 1)
      action.pay_sacrifice(boulder)
      action.targeting(p2)
    end
    game.stack.resolve!
    game.settle!

    expect(p2.life).to eq(16)
    expect(p1.creatures).not_to include(boulder)
  end

  it "can hit a creature" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 3)
    p1.activate_ability(ability: giant.activated_abilities.first) do |action|
      action.pay_mana(generic: { red: 2 }, red: 1)
      action.pay_sacrifice(boulders.first)
      action.targeting(victim)
    end
    game.stack.resolve!
    game.settle!

    expect(victim.card.zone).to be_graveyard
  end
end
