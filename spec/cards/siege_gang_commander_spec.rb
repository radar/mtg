# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SiegeGangCommander do
  include_context "two player game"

  let!(:commander) { ResolvePermanent("Siege Gang Commander", owner: p1) }

  def goblins = p1.creatures.select { |c| c.name == "Goblin" && c.token? }

  it "is a 2/2 Goblin" do
    expect([commander.power, commander.toughness]).to eq([2, 2])
    expect(commander.type?("Goblin")).to be true
  end

  it "creates three 1/1 red Goblin tokens" do
    expect(goblins.count).to eq(3)
    expect([goblins.first.power, goblins.first.toughness]).to eq([1, 1])
    expect(goblins.first.colors).to eq([:red])
  end

  it "sacrifices a Goblin for {1}{R} to deal 2 damage to any target" do
    p1.add_mana(red: 2)
    goblin = goblins.first

    p1.activate_ability(ability: commander.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 1 }, red: 1)
      a.pay_sacrifice(goblin) if a.respond_to?(:pay_sacrifice)
      a.targeting(p2)
    end
    game.stack.resolve!

    expect(p2.life).to eq(18)
    expect(goblins.count).to eq(2)
  end
end
