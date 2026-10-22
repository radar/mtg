# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpawnGangCommander do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Spawn-Gang Commander", owner: p1) }

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  def ability(commander) = commander.activated_abilities.first

  def activate(commander, sacrifice:, target: p2)
    p1.activate_ability(ability: ability(commander)) do |a|
      a.pay_mana(generic: { red: 1 }, colorless: 1)
      a.pay_sacrifice(sacrifice)
      a.targeting(target)
    end
    game.settle!
  end

  it "is a devoid 2/2 Eldrazi Goblin" do
    commander = ResolvePermanent("Spawn-Gang Commander", owner: p1)

    expect(commander.colors).to be_empty
    expect([commander.power, commander.toughness]).to eq([2, 2])
    expect(commander.type?("Eldrazi")).to be(true)
    expect(commander.type?("Goblin")).to be(true)
  end

  it "creates three 0/1 Eldrazi Spawn tokens when cast" do
    p1.add_mana(red: 5)
    p1.cast(card: card) { _1.pay_mana(generic: { red: 3 }, red: 2) }
    game.settle!

    expect(spawns.count).to eq(3)
    expect(spawns.map { [_1.power, _1.toughness] }.uniq).to eq([[0, 1]])
    expect(p1.creatures.map(&:name)).to include("Spawn-Gang Commander")
  end

  it "does not create Spawn when it enters without being cast" do
    ResolvePermanent("Spawn-Gang Commander", owner: p1)

    expect(spawns).to be_empty
  end

  context "with the commander and a Spawn on the battlefield" do
    let!(:commander) { ResolvePermanent("Spawn-Gang Commander", owner: p1) }
    let!(:spawn) do
      commander.create_eldrazi_spawn
      game.settle!
      spawns.first
    end

    it "pays {1}{C} and sacrifices an Eldrazi to deal 2 damage to any target" do
      p1.add_mana(red: 1, colorless: 1)

      activate(commander, sacrifice: spawn)

      expect(p2.life).to eq(18)
      expect(spawns).to be_empty
      expect(p1.mana_pool[:colorless]).to eq(0)
    end

    it "can sacrifice the commander itself, as it is an Eldrazi" do
      p1.add_mana(red: 1, colorless: 1)

      activate(commander, sacrifice: commander, target: p2)

      expect(p2.life).to eq(18)
      expect(p1.graveyard.cards.map(&:name)).to include("Spawn-Gang Commander")
    end

    it "only offers Eldrazi as sacrifice choices" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)

      cost = ability(commander).costs.find { _1.is_a?(Magic::Costs::Sacrifice) }

      expect(cost.choices).to include(spawn, commander)
      expect(cost.choices).not_to include(bears)
    end

    it "deals the 2 damage to a creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(red: 1, colorless: 1)

      activate(commander, sacrifice: spawn, target: bears)

      expect(bears.zone).to be_nil
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "cannot be paid with coloured mana for {C}" do
      p1.add_mana(red: 2)

      expect { activate(commander, sacrifice: spawn) }.to raise_error(StandardError)
      expect(p2.life).to eq(20)
    end
  end
end
