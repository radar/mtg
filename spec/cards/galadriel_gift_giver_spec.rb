# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GaladrielGiftGiver do
  include_context "two player game"

  def foods = p1.permanents.select { _1.type?("Food") }

  def treasures = p1.permanents.select { _1.type?("Treasure") }

  it "is a 4/4 legendary Elf Noble" do
    galadriel = ResolvePermanent("Galadriel, Gift-Giver", owner: p1)
    game.skip_choice!

    expect([galadriel.power, galadriel.toughness]).to eq([4, 4])
    expect(galadriel.card).to be_legendary
  end

  context "when it enters" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "can put a +1/+1 counter on another creature, including an opponent's" do
      ResolvePermanent("Galadriel, Gift-Giver", owner: p1)
      game.resolve_choice!(mode: :counter)
      game.resolve_choice!(target: theirs)
      game.tick!

      expect(theirs.power).to eq(3)
      expect(bears.power).to eq(2)
    end

    it "cannot put the counter on Galadriel herself" do
      galadriel = ResolvePermanent("Galadriel, Gift-Giver", owner: p1)
      game.resolve_choice!(mode: :counter)

      targets = game.choices.first.choices
      expect(targets).to contain_exactly(bears, theirs)
      expect(targets).not_to include(galadriel)
    end

    it "cannot target an opponent's hexproof creature" do
      hexproof = ResolvePermanent("Gigantic Big Bear", owner: p2)
      ResolvePermanent("Galadriel, Gift-Giver", owner: p1)
      game.resolve_choice!(mode: :counter)

      targets = game.choices.first.choices
      expect(targets).to contain_exactly(bears, theirs)
      expect(targets).not_to include(hexproof)
    end

    it "can create a Food token" do
      ResolvePermanent("Galadriel, Gift-Giver", owner: p1)
      game.resolve_choice!(mode: :food)

      expect(foods.count).to eq(1)
      expect(treasures.count).to eq(0)
    end

    it "can create a Treasure token" do
      ResolvePermanent("Galadriel, Gift-Giver", owner: p1)
      game.resolve_choice!(mode: :treasure)

      expect(treasures.count).to eq(1)
      expect(foods.count).to eq(0)
    end

    it "does nothing if the choice is skipped" do
      ResolvePermanent("Galadriel, Gift-Giver", owner: p1)
      game.skip_choice!

      expect(foods.count + treasures.count).to eq(0)
      expect(bears.power).to eq(2)
    end
  end

  context "when it attacks" do
    let!(:galadriel) do
      ResolvePermanent("Galadriel, Gift-Giver", owner: p1).tap { game.skip_choice! }
    end

    def attack_with(creature)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: creature, target: p2)
      current_turn.attackers_declared!
      game.settle!
    end

    it "offers the modes when Galadriel attacks" do
      attack_with(galadriel)
      game.resolve_choice!(mode: :treasure)

      expect(treasures.count).to eq(1)
    end

    it "can put a counter on another creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      attack_with(galadriel)
      game.resolve_choice!(mode: :counter)
      game.resolve_choice!(target: bears)
      game.tick!

      expect(theirs.power).to eq(2)
      expect(bears.power).to eq(3)
    end

    it "can create a Food token" do
      attack_with(galadriel)
      game.resolve_choice!(mode: :food)

      expect(foods.count).to eq(1)
    end

    it "does not trigger when another creature attacks" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(bears)

      expect(game.choices).to be_empty
    end
  end
end
