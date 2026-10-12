# frozen_string_literal: true

require "spec_helper"

# The nine Bloomburrow Talents that remain after Stormchaser's Talent (see class_enchantments_spec.rb).
RSpec.describe "Talent Class enchantments" do
  include_context "two player game"

  before { go_to_main_phase! }

  def talent(name, level: 1)
    ResolvePermanent(name, owner: p1).tap { |permanent| (level - 1).times { permanent.level_up! } }
  end

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def foods(player) = player.permanents.select { _1.type?("Food") }

  def attack_with(*creatures)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
  end

  describe "levelling" do
    it "enters at level 1 and levels up one level at a time as a sorcery" do
      permanent = talent("Scavenger's Talent")
      p1.add_mana(black: 2)
      ability = permanent.activated_abilities.find { _1.is_a?(Magic::Cards::ClassEnchantment::LevelUp) }
      p1.activate_ability(ability: ability) { _1.pay_mana(generic: { black: 1 }, black: 1) }
      game.stack.resolve!

      expect(permanent.level).to eq(2)
    end

    it "can't level up past its last level" do
      permanent = talent("Scavenger's Talent", level: 3)
      ability = permanent.activated_abilities.find { _1.is_a?(Magic::Cards::ClassEnchantment::LevelUp) }

      expect(ability.requirements_met?).to be false
    end
  end

  describe "Scavenger's Talent" do
    it "creates a Food whenever creatures you control die, once each turn" do
      talent("Scavenger's Talent")
      first = bear
      second = bear
      first.destroy!
      second.destroy!
      game.settle!

      expect(foods(p1).count).to eq(1)
    end

    it "ignores creatures an opponent controls" do
      talent("Scavenger's Talent")
      bear(owner: p2).destroy!
      game.settle!

      expect(foods(p1)).to be_empty
    end

    it "level 2 mills a player whenever you sacrifice a permanent" do
      talent("Scavenger's Talent", level: 2)
      bear.sacrifice!
      game.settle!
      before = p2.library.count
      game.resolve_choice!(target: p2)

      expect(p2.library.count).to eq(before - 2)
    end

    it "level 3 sacrifices three other nonland permanents at your end step to reanimate with a finality counter" do
      talent("Scavenger's Talent", level: 3)
      sacrifices = Array.new(3) { ResolvePermanent("Short Bow", owner: p1) }
      dead = Card("Nettle Guard", owner: p1).tap { p1.graveyard.add(_1) }
      current_turn.end!
      game.resolve_choice!
      game.resolve_choice!(permanents: sacrifices)
      game.settle!
      game.resolve_choice!(target: p2) while game.choices.first.is_a?(Magic::Cards::ScavengersTalent::SacrificeTrigger::MillChoice)
      game.resolve_choice!(target: dead) if game.choices.any?
      returned = p1.creatures.find { _1.name == "Nettle Guard" }

      expect(returned).not_to be_nil
      expect(returned.counters.of_type(Magic::Counters["finality"]).count).to eq(1)

      returned.destroy!
      expect(game.exile.cards).to include(dead)
    end
  end

  describe "Bandit's Talent" do
    it "makes each opponent discard two cards unless they discard a nonland card" do
      p2.hand.add(Card("Grizzly Bears", owner: p2))
      talent("Bandit's Talent")
      choice = game.choices.first

      expect(choice.controller).to eq(p2)
      before = p2.hand.count
      game.resolve_choice!(cards: [p2.hand.cards.find { !_1.land? }])
      expect(p2.hand.count).to eq(before - 1)
    end

    it "accepts discarding two cards" do
      talent("Bandit's Talent")
      before = p2.hand.count
      game.resolve_choice!(cards: p2.hand.first(2))

      expect(p2.hand.count).to eq(before - 2)
    end

    it "level 2 makes an opponent with one or fewer cards in hand lose 2 life at their upkeep" do
      talent("Bandit's Talent", level: 2)
      game.resolve_choice!(cards: p2.hand.first(2))
      [*p2.hand.cards].drop(1).each(&:discard!)
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
      game.settle!

      expect(p2.life).to eq(18)
    end

    it "level 2 does nothing to an opponent holding more cards" do
      talent("Bandit's Talent", level: 2)
      game.resolve_choice!(cards: p2.hand.first(2))
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
      game.settle!

      expect(p2.life).to eq(20)
    end

    it "level 3 draws an extra card for each opponent with one or fewer cards in hand" do
      talent("Bandit's Talent", level: 3)
      game.resolve_choice!(cards: p2.hand.first(2))
      [*p2.hand.cards].drop(1).each(&:discard!)
      before = p1.hand.count
      game.notify!(Magic::Events::DrawStep.new(player: p1))
      game.settle!

      expect(p1.hand.count).to eq(before + 1)
    end
  end

  describe "Innkeeper's Talent" do
    it "puts a +1/+1 counter on target creature you control at the beginning of combat on your turn" do
      talent("Innkeeper's Talent")
      creature = bear
      current_turn.beginning_of_combat!
      game.settle!
      game.tick!

      expect(creature.power).to eq(3)
    end

    it "level 2 gives permanents with counters ward {1}" do
      talent("Innkeeper's Talent", level: 2)
      creature = bear
      creature.add_counter("+1/+1")
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) { _1.auto_pay_mana; _1.targeting(creature) }
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::Ward)
      game.resolve_choice!
      expect(p2.graveyard.cards.map(&:name)).to include("Titanic Growth")
    end

    it "level 2 gives no ward to a permanent without counters" do
      talent("Innkeeper's Talent", level: 2)
      creature = bear
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) { _1.auto_pay_mana; _1.targeting(creature) }
      game.settle!

      expect(game.choices).to be_empty
    end

    it "level 3 doubles the counters you put on permanents" do
      talent("Innkeeper's Talent", level: 3)
      creature = bear
      creature.add_counter("+1/+1")

      expect(creature.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "doesn't double counters before level 3" do
      talent("Innkeeper's Talent")
      creature = bear
      creature.add_counter("+1/+1")

      expect(creature.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end
  end

  describe "Hunter's Talent" do
    it "has your creature deal damage equal to its power to a creature you don't control when it enters" do
      mine = ResolvePermanent("Nettle Guard", owner: p1)
      theirs = bear(owner: p2)
      talent("Hunter's Talent")

      expect(theirs.zone).to be_nil
      expect(mine.damage).to eq(0)
    end

    it "level 2 gives an attacking creature +1/+0 and trample whenever you attack" do
      talent("Hunter's Talent", level: 2)
      attacker = bear
      attack_with(attacker)
      game.settle!
      game.tick!

      expect(attacker.power).to eq(3)
      expect(attacker.keywords).to include(Magic::Cards::Keywords::TRAMPLE)
    end

    it "level 3 draws a card at your end step if you control a creature with power 4 or greater" do
      talent("Hunter's Talent", level: 3)
      ResolvePermanent("Quaketusk Boar", owner: p1)
      before = p1.hand.count
      current_turn.end!
      game.settle!

      expect(p1.hand.count).to eq(before + 1)
    end

    it "level 3 doesn't draw without a big creature" do
      talent("Hunter's Talent", level: 3)
      bear
      before = p1.hand.count
      current_turn.end!
      game.settle!

      expect(p1.hand.count).to eq(before)
    end
  end

  describe "Gossip's Talent" do
    it "surveils 1 whenever a creature you control enters" do
      talent("Gossip's Talent")
      bear
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::Surveil)
    end

    it "level 2 makes an attacking creature with power 3 or less unblockable" do
      talent("Gossip's Talent", level: 2)
      attacker = bear
      game.skip_choice! if game.choices.any?
      attack_with(attacker)
      game.settle!

      expect(attacker.can_be_blocked?(bear(owner: p2))).to be false
    end

    it "level 3 may exile a creature that dealt combat damage to a player and return it" do
      talent("Gossip's Talent", level: 3)
      attacker = bear
      game.skip_choice! if game.choices.any?
      attacker.add_counter("+1/+1")
      game.notify!(Magic::Events::CombatDamageDealt.new(source: attacker, target: p2, damage: 2))
      game.settle!
      game.resolve_choice!

      returned = p1.creatures.find { _1.name == "Grizzly Bears" }
      expect(returned).not_to be_nil
      expect(returned.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
    end
  end

  describe "Caretaker's Talent" do
    it "draws a card the first time tokens enter each turn" do
      talent("Caretaker's Talent")
      before = p1.hand.count
      Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      game.settle!

      expect(p1.hand.count).to eq(before + 1)
    end

    it "level 2 creates a copy of a token you control" do
      talent("Caretaker's Talent", level: 1)
      food = Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      game.settle!
      permanent = p1.permanents.find { _1.name == "Caretaker's Talent" }
      permanent.level_up!
      game.settle!
      game.resolve_choice!(target: food) if game.choices.any?

      expect(foods(p1).count).to eq(2)
    end

    it "level 3 gives creature tokens you control +2/+2" do
      talent("Caretaker's Talent", level: 3)
      token = Magic::Tokens::Fish.new(game: game, owner: p1).resolve!
      game.tick!

      expect(token.power).to eq(3)
      expect(token.toughness).to eq(3)
      expect(bear.power).to eq(2)
    end
  end

  describe "Builder's Talent" do
    it "creates a 0/4 Wall with defender when it enters" do
      talent("Builder's Talent")
      wall = p1.creatures.find { _1.name == "Wall" }

      expect([wall.power, wall.toughness]).to eq([0, 4])
      expect(wall.keywords).to include(Magic::Cards::Keywords::DEFENDER)
    end

    it "level 2 puts a +1/+1 counter on a creature when a noncreature nonland permanent enters" do
      talent("Builder's Talent", level: 2)
      creature = bear
      ResolvePermanent("Short Bow", owner: p1)
      game.settle!
      game.resolve_choice!(target: creature)
      game.tick!

      expect(creature.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end

    it "level 3 returns a noncreature nonland permanent card from your graveyard to the battlefield" do
      permanent = talent("Builder's Talent", level: 2)
      bow = Card("Short Bow", owner: p1).tap { p1.graveyard.add(_1) }
      permanent.level_up!
      game.settle!
      game.resolve_choice!(target: bow) if game.choices.any?

      expect(p1.permanents.map(&:name)).to include("Short Bow")
    end
  end

  describe "Blacksmith's Talent" do
    it "creates a Sword equipment token with equip {2}" do
      talent("Blacksmith's Talent")
      sword = p1.permanents.find { _1.name == "Sword" }
      creature = bear

      expect(sword.type?("Equipment")).to be true
      p1.add_mana(red: 2)
      equip = sword.activated_abilities.first
      p1.activate_ability(ability: equip) { _1.pay_mana(generic: { red: 2 }).targeting(creature) }
      game.stack.resolve!
      game.tick!

      expect(creature.power).to eq(3)
      expect(creature.toughness).to eq(3)
    end

    it "level 2 attaches an Equipment to a creature at the beginning of combat" do
      talent("Blacksmith's Talent", level: 2)
      creature = bear
      sword = p1.permanents.find { _1.name == "Sword" }
      current_turn.beginning_of_combat!
      game.settle!
      game.resolve_choice!(target: sword) if game.choices.any? && game.choices.first.choices.include?(sword)
      game.resolve_choice!(target: creature) if game.choices.any?
      game.tick!

      expect(sword.attached_to).to eq(creature)
    end

    it "level 3 gives equipped creatures double strike and haste on your turn" do
      talent("Blacksmith's Talent", level: 3)
      creature = bear
      sword = p1.permanents.find { _1.name == "Sword" }
      sword.attach_to!(creature)
      game.tick!

      expect(creature.keywords).to include(Magic::Cards::Keywords::DOUBLE_STRIKE, Magic::Cards::Keywords::HASTE)
    end
  end

  describe "Artist's Talent" do
    it "lets you discard a card to draw a card whenever you cast a noncreature spell" do
      talent("Artist's Talent")
      creature = bear
      discarded = p1.hand.first
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(creature) }
      game.settle!
      game.resolve_choice!
      game.resolve_choice!(card: discarded)

      expect(p1.graveyard.cards).to include(discarded)
    end

    it "level 2 makes noncreature spells cost {1} less" do
      talent("Artist's Talent", level: 2)
      creature = bear
      p1.add_mana(green: 1)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.pay_mana(green: 1).targeting(creature) }

      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "level 3 adds 2 to noncombat damage dealt to an opponent" do
      talent("Artist's Talent", level: 3)
      p1.add_mana(red: 3)
      p1.cast(card: Card("Flame Lash", owner: p1)) { _1.auto_pay_mana; _1.targeting(p2) }
      game.settle!
      game.skip_choice! if game.choices.any?
      game.stack.resolve!

      expect(p2.life).to eq(20 - 4 - 2)
    end
  end
end
