# frozen_string_literal: true

require "spec_helper"

# Bloomburrow artifacts, enchantments, Auras and the creatures with modal enters-the-battlefield triggers.
RSpec.describe "Bloomburrow assorted permanents" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent, type = Magic::Counters::Plus1Plus1) = permanent.counters.of_type(type).count

  describe "Sinister Monolith" do
    let!(:monolith) { ResolvePermanent("Sinister Monolith", owner: p1) }

    it "drains each opponent at the beginning of combat on your turn" do
      current_turn.beginning_of_combat!
      game.settle!

      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
    end

    it "draws two cards for {T}, 2 life and a sacrifice, as a sorcery" do
      before = p1.hand.count
      p1.activate_ability(ability: monolith.activated_abilities.first)
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 2)
      expect(p1.life).to eq(18)
    end
  end

  describe "Stocking the Pantry" do
    it "gets a supply counter for +1/+1 counters on your creatures and draws for {2}" do
      pantry = ResolvePermanent("Stocking The Pantry", owner: p1)
      creature = bear
      creature.add_counter("+1/+1")
      game.settle!
      expect(counters(pantry, Magic::Counters["supply"])).to eq(1)

      p1.add_mana(green: 2)
      before = p1.hand.count
      p1.activate_ability(ability: pantry.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }) }
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 1)
      expect(counters(pantry, Magic::Counters["supply"])).to eq(0)
    end
  end

  describe "War Squeak" do
    it "gives +1/+1 and haste, and stops an opposing creature blocking" do
      victim = bear(owner: p2)
      target = bear
      aura = Card("War Squeak", owner: p1)
      p1.add_mana(red: 1)
      p1.cast(card: aura) { _1.auto_pay_mana; _1.targeting(target) }
      game.stack.resolve!
      game.settle!
      game.resolve_choice!(target: victim) if game.choices.any?
      game.tick!

      expect(target.power).to eq(3)
      expect(target.keywords).to include(Magic::Cards::Keywords::HASTE)
      expect(victim.can_block?(target)).to be false
    end
  end

  describe "Otterball Antics" do
    it "creates an Otter from your hand" do
      p1.add_mana(blue: 2)
      p1.cast(card: Card("Otterball Antics", owner: p1)) { _1.auto_pay_mana }
      game.stack.resolve!
      otter = p1.creatures.find { _1.name == "Otter" }

      expect(counters(otter)).to eq(0)
    end

    it "creates an Otter with a +1/+1 counter when flashed back" do
      card = Card("Otterball Antics", owner: p1)
      p1.graveyard.add(card)
      p1.add_mana(blue: 4)
      p1.cast_as(:flashback, card: card) { _1.auto_pay_mana }
      game.stack.resolve!
      otter = p1.creatures.find { _1.name == "Otter" }

      expect(counters(otter)).to eq(1)
    end
  end

  describe "Ruthless Negotiation" do
    it "makes the opponent exile a card from their hand" do
      before = p2.hand.count
      p1.add_mana(black: 1)
      p1.cast(card: Card("Ruthless Negotiation", owner: p1)) { _1.auto_pay_mana; _1.targeting(p2) }
      game.stack.resolve!
      game.resolve_choice!(card: p2.hand.first)

      expect(p2.hand.count).to eq(before - 1)
    end
  end

  describe "Hoarder's Overflow" do
    it "gets stash counters and trades your hand for a card per counter" do
      overflow = ResolvePermanent("Hoarder's Overflow", owner: p1)
      expect(counters(overflow, Magic::Counters["stash"])).to eq(1)

      p1.add_mana(red: 2)
      p1.activate_ability(ability: overflow.activated_abilities.first) do |action|
        action.pay_mana(generic: { red: 1 }, red: 1)
        action.pay_self_sacrifice
      end
      game.stack.resolve!

      expect(p1.hand.count).to eq(1)
    end
  end

  describe "Valley Floodcaller" do
    it "lets you cast noncreature spells as though they had flash" do
      ResolvePermanent("Valley Floodcaller", owner: p1)
      action = p1.prepare_cast(card: Card("Short Bow", owner: p1))

      expect(action.instant_speed?).to be true
    end

    it "pumps and untaps Birds, Frogs, Otters and Rats when you cast a noncreature spell" do
      ResolvePermanent("Valley Floodcaller", owner: p1)
      frog = ResolvePermanent("Valley Mightcaller", owner: p1)
      frog.tap!
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(frog) }
      game.settle!
      game.stack.resolve!
      game.tick!

      expect(frog).not_to be_tapped
      expect(frog.power).to eq(1 + 1 + 4)
    end
  end

  describe "Stormsplitter" do
    it "creates a temporary copy when you cast an instant or sorcery" do
      splitter = ResolvePermanent("Stormsplitter", owner: p1)
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(splitter) }
      game.settle!
      expect(p1.creatures.count { _1.name == "Stormsplitter" }).to eq(2)

      game.stack.resolve!
      current_turn.end!
      game.settle!
      expect(p1.creatures.count { _1.name == "Stormsplitter" }).to eq(1)
    end
  end

  describe "Downwind Ambusher" do
    it "gives an opposing creature -1/-1" do
      victim = bear(owner: p2)
      ResolvePermanent("Downwind Ambusher", owner: p1)
      game.resolve_choice!(mode: :shrink)
      game.resolve_choice!(target: victim) if game.choices.any?
      game.tick!

      expect(victim.toughness).to eq(1)
    end

    it "destroys an opposing creature that was dealt damage this turn" do
      victim = bear(owner: p2)
      victim.trigger_effect(:deal_damage, target: victim, damage: 1)
      game.settle!
      ResolvePermanent("Downwind Ambusher", owner: p1)
      game.resolve_choice!(mode: :destroy)
      game.resolve_choice!(target: victim) if game.choices.any?

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "Hivespine Wolverine" do
    it "can put a +1/+1 counter on a creature you control" do
      ally = bear
      ResolvePermanent("Hivespine Wolverine", owner: p1)
      game.resolve_choice!(mode: :counter)
      game.resolve_choice!(target: ally) if game.choices.any?

      expect(counters(ally)).to eq(1)
    end

    it "can destroy an artifact" do
      bow = ResolvePermanent("Short Bow", owner: p2)
      ResolvePermanent("Hivespine Wolverine", owner: p1)
      game.resolve_choice!(mode: :destroy)
      game.resolve_choice!(target: bow) if game.choices.any?

      expect(p2.graveyard.cards.map(&:name)).to include("Short Bow")
    end
  end
end
