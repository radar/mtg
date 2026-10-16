# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BaskingBroodscale do
  include_context "two player game"

  let!(:broodscale) { ResolvePermanent("Basking Broodscale", owner: p1) }

  def spawns = p1.creatures.select { _1.token? && _1.name == "Eldrazi Spawn" }

  def adapt
    p1.add_mana(green: 2)
    p1.activate_ability(ability: broodscale.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a colorless 2/2 Eldrazi Lizard (devoid)" do
    expect(broodscale.colors).to eq([])
    expect([broodscale.power, broodscale.toughness]).to eq([2, 2])
    expect(broodscale.type?("Eldrazi")).to be(true)
    expect(broodscale.type?("Lizard")).to be(true)
  end

  context "{1}{G}: Adapt 1" do
    it "puts a +1/+1 counter on it when it has none" do
      adapt
      game.skip_choice!
      game.settle!

      expect([broodscale.power, broodscale.toughness]).to eq([3, 3])
      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "does nothing, though the mana is spent, when it already has a +1/+1 counter" do
      adapt
      game.skip_choice!
      game.settle!
      adapt

      expect([broodscale.power, broodscale.toughness]).to eq([3, 3])
      expect(game.choices).to be_empty
      expect(spawns).to be_empty
    end

    it "can't be activated without the mana" do
      p1.add_mana(green: 1)

      expect do
        p1.activate_ability(ability: broodscale.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      end.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(broodscale.counters).to be_empty
    end
  end

  context "whenever one or more +1/+1 counters are put on it" do
    it "offers a may choice and creates a 0/1 colorless Eldrazi Spawn on accepting" do
      adapt

      expect(game.choices.first).to be_a(Magic::Choice::May)
      game.resolve_choice!
      game.settle!

      expect(spawns.size).to eq(1)
      spawn = spawns.first
      expect([spawn.power, spawn.toughness]).to eq([0, 1])
      expect(spawn.colors).to eq([])
      expect(spawn.type?("Eldrazi")).to be(true)
    end

    it "creates no token when the choice is declined" do
      adapt
      game.skip_choice!
      game.settle!

      expect(spawns).to be_empty
    end

    it "triggers once for a group of several counters" do
      broodscale.add_counter("+1/+1", amount: 2)
      game.settle!

      expect(game.choices.size).to eq(1)
      expect(broodscale.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "triggers for counters put on it by other effects" do
      broodscale.add_counter("+1/+1")
      game.settle!

      expect(game.choices.size).to eq(1)
    end

    it "does not trigger for a +1/+1 counter on another creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_counter("+1/+1")
      game.settle!

      expect(game.choices).to be_empty
    end

    it "does not trigger for a different kind of counter on it" do
      broodscale.add_counter("-1/-1")
      game.settle!

      expect(game.choices).to be_empty
    end

    it "makes a Spawn that can be sacrificed for {C}" do
      adapt
      game.resolve_choice!
      game.settle!
      spawn = spawns.first
      p1.activate_ability(ability: spawn.activated_abilities.first)
      game.settle!

      expect(spawns).to be_empty
      expect(p1.mana_pool[:colorless]).to eq(1)
    end
  end
end
