# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SarpadianSimulacrum do
  include_context "two player game"

  let!(:simulacrum) { ResolvePermanent("Sarpadian Simulacrum", owner: p1) }

  it "is a 1/1 artifact Goblin creature with haste" do
    expect(simulacrum.power).to eq(1)
    expect(simulacrum.toughness).to eq(1)
    expect(simulacrum.types).to include("Goblin", "Artifact", "Creature")
    expect(simulacrum).to be_haste
  end

  it "sacrifices itself for {3}{R} to deal 4 damage to target creature" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 4)
    p1.activate_ability(ability: simulacrum.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 3 }, red: 1)
      a.targeting(victim)
    end
    expect(p1.graveyard.cards.map(&:name)).to include("Sarpadian Simulacrum")
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "does not kill a creature with toughness above 4" do
    victim = ResolvePermanent("Alpha Tyrranax", owner: p2)
    p1.add_mana(red: 4)
    p1.activate_ability(ability: simulacrum.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 3 }, red: 1)
      a.targeting(victim)
    end
    game.stack.resolve!
    game.settle!

    expect(p2.creatures).to include(victim)
  end

  it "can't be activated without {3}{R}" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 2)
    expect do
      p1.activate_ability(ability: simulacrum.activated_abilities.first) do |a|
        a.pay_mana(generic: { red: 1 }, red: 1)
        a.targeting(victim)
      end
    end.to raise_error(StandardError)
  end
end
