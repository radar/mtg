# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KrenkoMobBoss do
  include_context "two player game"

  let!(:krenko) { ResolvePermanent("Krenko, Mob Boss", owner: p1) }

  def goblins = p1.creatures.select { _1.type?("Goblin") }

  it "is a 3/3 legendary Goblin Warrior" do
    expect([krenko.power, krenko.toughness]).to eq([3, 3])
  end

  it "creates a number of 1/1 red Goblin tokens equal to the Goblins you control" do
    p1.activate_ability(ability: krenko.activated_abilities.first)
    game.stack.resolve!
    game.settle!

    expect(goblins.count).to eq(2) # Krenko plus one token
    expect(krenko).to be_tapped
  end

  it "makes more tokens the next time" do
    p1.activate_ability(ability: krenko.activated_abilities.first)
    game.stack.resolve!
    krenko.untap!
    p1.activate_ability(ability: krenko.activated_abilities.first)
    game.stack.resolve!
    game.settle!

    expect(goblins.count).to eq(4) # 1 + 1 + 2
  end
end
