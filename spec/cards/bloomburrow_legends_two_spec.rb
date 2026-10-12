# frozen_string_literal: true

require "spec_helper"

# More Bloomburrow legends, the Starforged Sword, Sugar Coat and the vehicle.
RSpec.describe "Bloomburrow legends, part two" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  describe "Dragonhawk, Fate's Tempest" do
    it "exiles cards for each creature with power 4 or greater and burns for those still exiled" do
      hawk = ResolvePermanent("Dragonhawk, Fate's Tempest", owner: p1)
      game.settle!

      expect(game.exile.cards.size).to eq(1)
      current_turn.end!
      game.settle!

      expect(p2.life).to eq(18)
      expect(hawk).not_to be_nil
    end
  end

  describe "Helga, Skittish Seer" do
    let!(:helga) { ResolvePermanent("Helga, Skittish Seer", owner: p1) }

    it "draws, gains life and grows when you cast a big creature spell" do
      before = p1.hand.count
      p1.add_mana(red: 5)
      p1.cast(card: Card("Quaketusk Boar", owner: p1)) { _1.auto_pay_mana }
      game.settle!
      game.tick!

      expect(p1.hand.count).to eq(before + 1)
      expect(p1.life).to eq(21)
      expect(counters(helga)).to eq(1)
    end

    it "taps for X mana of one color usable only on big creature spells" do
      p1.activate_ability(ability: helga.activated_abilities.first) { _1.choose(:green) }

      expect(p1.spendable_mana_for(Card("Pileated Provisioner", owner: p1))[:green]).to eq(1)
      expect(p1.spendable_mana_for(Card("Grizzly Bears", owner: p1))[:green]).to eq(0)
    end
  end

  describe "Hugs, Grisly Guardian" do
    it "allows an additional land each turn" do
      hugs = ResolvePermanent("Hugs, Grisly Guardian", owner: p1)

      expect(hugs.additional_lands_per_turn).to eq(1)
    end
  end

  describe "Kastral, the Windcrested" do
    let!(:kastral) { ResolvePermanent("Kastral, The Windcrested", owner: p1) }

    def bird_hits_player
      game.notify!(Magic::Events::CombatDamageDealt.new(source: kastral, target: p2, damage: 4))
      game.settle!
    end

    it "draws a card" do
      before = p1.hand.count
      bird_hits_player
      game.resolve_choice!(mode: :draw)

      expect(p1.hand.count).to eq(before + 1)
    end

    it "puts a +1/+1 counter on each Bird" do
      bird_hits_player
      game.resolve_choice!(mode: :counters)

      expect(counters(kastral)).to eq(1)
    end

    it "puts a Bird from your hand onto the battlefield with a finality counter" do
      bird = Card("Pileated Provisioner", owner: p1).tap { p1.hand.add(_1) }
      bird_hits_player
      game.resolve_choice!(mode: :put_bird)
      game.resolve_choice!(target: bird) if game.choices.any?
      returned = p1.creatures.find { _1.name == "Pileated Provisioner" }

      expect(returned.counters.of_type(Magic::Counters["finality"]).count).to eq(1)
    end
  end

  describe "Starforged Sword" do
    it "gives +3/+3 and removes flying, with equip {3}" do
      sword = ResolvePermanent("Starforged Sword", owner: p1)
      flyer = ResolvePermanent("Pileated Provisioner", owner: p1)
      game.skip_choice! while game.choices.any?
      sword.attach_to!(flyer)
      game.tick!

      expect(flyer.power).to eq(6)
      expect(flyer.keywords).not_to include(Magic::Cards::Keywords::FLYING)
    end

    it "attaches itself to a creature when it enters with the gift promised" do
      target = bear
      p1.add_mana(colorless: 4)
      p1.cast(card: Card("Starforged Sword", owner: p1)) do |action|
        action.promise_gift
        action.pay_mana(generic: { colorless: 4 })
      end
      game.stack.resolve!
      game.settle!
      game.resolve_choice!(target: target) if game.choices.any?
      game.tick!

      expect(target.power).to eq(5)
    end
  end

  describe "Sugar Coat" do
    it "turns a creature into a colorless Food artifact without abilities" do
      victim = ResolvePermanent("Nettle Guard", owner: p2)
      p1.add_mana(blue: 3)
      p1.cast(card: Card("Sugar Coat", owner: p1)) { _1.auto_pay_mana; _1.targeting(victim) }
      game.stack.resolve!
      game.tick!

      expect(victim.type?("Food")).to be true
      expect(victim.type?("Creature")).to be false
      expect(victim.colors).to be_empty
    end
  end

  describe "Ral, Crackling Wit" do
    let!(:ral) { ResolvePermanent("Ral, Crackling Wit", owner: p1) }

    it "gains loyalty when you cast a noncreature spell" do
      target = bear
      before = ral.loyalty
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(target) }
      game.settle!

      expect(ral.loyalty).to eq(before + 1)
    end

    it "+1 creates an Otter token" do
      p1.activate_loyalty_ability(ability: ral.loyalty_abilities.first)
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Otter")
    end

    it "-10 draws three cards and gets a storm emblem" do
      ral.change_loyalty!(10)
      before = p1.hand.count
      p1.activate_loyalty_ability(ability: ral.loyalty_abilities.last)
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 3)
      expect(game.emblems.count).to eq(1)
    end
  end

  describe "Mockingbird" do
    it "may enter as a copy of a creature with mana value up to the mana spent, with flying and Bird" do
      ResolvePermanent("Seasoned Warrenguard", owner: p1)
      p1.add_mana(blue: 3)
      p1.cast(card: Card("Mockingbird", owner: p1), value_for_x: 2) do |action|
        action.pay_mana(x: { blue: 2 }, blue: 1)
      end
      game.stack.resolve!
      game.settle!
      game.resolve_choice!
      game.resolve_choice!(target: p1.creatures.find { _1.name == "Seasoned Warrenguard" }) if game.choices.any?
      game.tick!
      copy = p1.creatures.find { _1.name == "Seasoned Warrenguard" && _1.type?("Bird") }

      expect(copy).not_to be_nil
      expect(copy.keywords).to include(Magic::Cards::Keywords::FLYING)
    end
  end

  describe "Alania, Divergent Storm" do
    it "copies the first instant you cast each turn when the opponent draws" do
      ResolvePermanent("Alania, Divergent Storm", owner: p1)
      target = bear
      before = p2.hand.count
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(target) }
      game.settle!
      game.resolve_choice!
      game.resolve_choice!
      game.resolve_choice!(target: target)
      game.stack.resolve!
      game.tick!

      expect(p2.hand.count).to eq(before + 1)
      expect(target.power).to eq(2 + 4 + 4)
    end
  end

  describe "The Infamous Cruelclaw" do
    it "exiles until a nonland card and may cast it by discarding a card" do
      cruelclaw = ResolvePermanent("The Infamous Cruelclaw", owner: p1)
      spell = Card("Titanic Growth", owner: p1)
      p1.library.add(spell)
      game.notify!(Magic::Events::CombatDamageDealt.new(source: cruelclaw, target: p2, damage: 3))
      game.settle!
      game.resolve_choice!
      game.resolve_choice!(card: p1.hand.first)
      game.stack.resolve!
      game.tick!

      expect(cruelclaw.power).to eq(7)
    end
  end

  describe "For the Common Good" do
    it "copies a token X times, makes tokens indestructible and gains 1 life per token" do
      token = Magic::Tokens::Fish.new(game: game, owner: p1).resolve!
      p1.add_mana(green: 5)
      p1.cast(card: Card("For The Common Good", owner: p1), value_for_x: 2) do |action|
        action.pay_mana(x: { green: 4 }, green: 1)
        action.targeting(token)
      end
      game.stack.resolve!

      expect(p1.permanents.count(&:token?)).to eq(3)
      expect(p1.life).to eq(23)
    end
  end

  describe "Tangle Tumbler" do
    it "becomes a creature by tapping two tokens" do
      tumbler = ResolvePermanent("Tangle Tumbler", owner: p1)
      tokens = Array.new(2) { Magic::Tokens::Fish.new(game: game, owner: p1).resolve! }
      p1.activate_ability(ability: tumbler.activated_abilities.last) { _1.pay_multi_tap(tokens) }
      game.stack.resolve!
      game.tick!

      expect(tumbler.creature?).to be true
      expect(tumbler.power).to eq(6)
    end
  end
end
