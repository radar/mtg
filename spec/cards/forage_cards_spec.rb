# frozen_string_literal: true

require "spec_helper"

# Forage: exile three cards from your graveyard or sacrifice a Food.
RSpec.describe "Forage cards" do
  include_context "two player game"

  before { go_to_main_phase! }

  def fill_graveyard(count = 3)
    Array.new(count) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
  end

  def make_food
    Magic::Tokens::Food.new(game: game, owner: p1).resolve!
  end

  describe "Player#forage!" do
    it "exiles three cards from the graveyard" do
      cards = fill_graveyard
      p1.forage!(cards)

      expect(p1.graveyard.count).to eq(0)
      expect(game.exile.cards).to include(*cards)
    end

    it "sacrifices a Food" do
      food = make_food
      p1.forage!(food)

      expect(game.battlefield.cards).not_to include(food)
    end

    it "needs three cards or a Food" do
      expect(p1.can_forage?).to be false
      fill_graveyard(2)
      expect(p1.can_forage?).to be false
      make_food
      expect(p1.can_forage?).to be true
    end

    it "rejects a payment that isn't three graveyard cards" do
      cards = fill_graveyard(2)

      expect { p1.forage!(cards) }.to raise_error(/three cards/)
    end
  end

  describe "Bushy Bodyguard" do
    it "puts two +1/+1 counters on itself when you forage" do
      cards = fill_graveyard
      creature = ResolvePermanent("Bushy Bodyguard", owner: p1)
      game.resolve_choice!
      game.resolve_choice!(payment: cards)
      game.tick!

      expect(creature.power).to eq(4)
      expect(creature.toughness).to eq(3)
    end

    it "does nothing when you decline" do
      fill_graveyard
      creature = ResolvePermanent("Bushy Bodyguard", owner: p1)
      game.skip_choice!

      expect(creature.power).to eq(2)
    end
  end

  describe "Curious Forager" do
    it "returns a permanent card from your graveyard to your hand when you forage" do
      cards = fill_graveyard
      target = Card("Short Bow", owner: p1).tap { p1.graveyard.add(_1) }
      ResolvePermanent("Curious Forager", owner: p1)
      game.resolve_choice!
      game.resolve_choice!(payment: cards)
      game.resolve_choice!(target: target) if game.choices.any?

      expect(p1.hand.cards).to include(target)
    end
  end

  describe "Treetop Sentries" do
    it "draws a card when you forage" do
      food = make_food
      before = p1.hand.count
      ResolvePermanent("Treetop Sentries", owner: p1)
      game.resolve_choice!
      game.resolve_choice!(payment: food)

      expect(p1.hand.count).to eq(before + 1)
    end
  end

  describe "Corpseberry Cultivator" do
    it "gets a +1/+1 counter whenever you forage" do
      creature = ResolvePermanent("Corpseberry Cultivator", owner: p1)
      p1.forage!(make_food)
      game.settle!
      game.tick!

      expect(creature.power).to eq(3)
    end

    it "may forage at the beginning of combat on your turn" do
      creature = ResolvePermanent("Corpseberry Cultivator", owner: p1)
      food = make_food
      current_turn.beginning_of_combat!
      game.resolve_choice!
      game.resolve_choice!(payment: food)
      game.settle!
      game.tick!

      expect(creature.power).to eq(3)
    end
  end

  describe "Feed the Cycle" do
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "can be cast by foraging" do
      cards = fill_graveyard
      p1.add_mana(black: 2)
      p1.cast(card: Card("Feed The Cycle", owner: p1)) do |action|
        action.pay_mana(generic: { black: 1 }, black: 1)
        action.pay_forage(cards)
        action.targeting(bear)
      end
      game.stack.resolve!

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "can be cast by paying {B} instead" do
      p1.add_mana(black: 3)
      p1.cast(card: Card("Feed The Cycle", owner: p1)) do |action|
        action.pay_mana(generic: { black: 1 }, black: 1)
        action.pay_forage(black: 1)
        action.targeting(bear)
      end
      game.stack.resolve!

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "can't be cast without paying either" do
      p1.add_mana(black: 2)

      expect {
        p1.cast(card: Card("Feed The Cycle", owner: p1)) do |action|
          action.pay_mana(generic: { black: 1 }, black: 1)
          action.targeting(bear)
        end
      }.to raise_error(/Additional costs have not been paid/)
    end
  end

  describe "Thornvault Forager" do
    let!(:forager) { ResolvePermanent("Thornvault Forager", owner: p1) }

    it "taps for {G}" do
      p1.activate_ability(ability: forager.activated_abilities.first)

      expect(p1.mana_pool[:green]).to eq(1)
    end

    it "adds two mana in any combination of colors by foraging" do
      food = make_food
      p1.activate_ability(ability: forager.activated_abilities[1]) do |action|
        action.pay_forage(food)
        action.choose(%i[blue red])
      end

      expect(p1.mana_pool[:blue]).to eq(1)
      expect(p1.mana_pool[:red]).to eq(1)
      expect(game.battlefield.cards).not_to include(food)
    end
  end

  describe "Camellia, the Seedmiser" do
    let!(:camellia) { ResolvePermanent("Camellia, The Seedmiser", owner: p1) }
    let!(:squirrel) { ResolvePermanent("Bushy Bodyguard", owner: p1) }

    before { game.skip_choice! if game.choices.any? }

    it "gives other Squirrels menace" do
      game.tick!

      expect(squirrel.keywords).to include(Magic::Cards::Keywords::MENACE)
    end

    it "creates a Squirrel token whenever you sacrifice a Food" do
      make_food.sacrifice!
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Squirrel")
    end

    it "puts a +1/+1 counter on each other Squirrel for {2} and a forage" do
      food = make_food
      p1.add_mana(green: 2)
      p1.activate_ability(ability: camellia.activated_abilities.first) do |action|
        action.pay_mana(generic: { green: 2 })
        action.pay_forage(food)
      end
      game.stack.resolve!
      game.tick!

      expect(squirrel.power).to eq(3)
      expect(camellia.power).to eq(3)
    end
  end
end
