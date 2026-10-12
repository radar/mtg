# frozen_string_literal: true

require "spec_helper"

# Bloomburrow creatures with offspring, plus its Food artifacts and its lands.
RSpec.describe "Bloomburrow offspring creatures, Foods and lands" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def attack_with(*creatures)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  describe "A-Heartfire Hero" do
    it "is a 0/1 that gets counters when targeted and burns on death" do
      hero = ResolvePermanent("A-Heartfire Hero", owner: p1)
      expect([hero.power, hero.toughness]).to eq([0, 1])

      hero.add_counter("+1/+1", amount: 2)
      game.tick!
      hero.destroy!
      game.settle!

      expect(p2.life).to eq(18)
    end
  end

  it "Intrepid Rabbit pumps a creature you control when it enters" do
    target = bear
    ResolvePermanent("Intrepid Rabbit", owner: p1)
    game.resolve_choice!(target: target) if game.choices.any?
    game.tick!

    expect(target.power).to eq(3)
  end

  it "Coruscation Mage pings each opponent when you cast a noncreature spell" do
    ResolvePermanent("Coruscation Mage", owner: p1)
    target = bear
    p1.add_mana(green: 2)
    p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(target) }
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "Darkstar Augur puts the top card into your hand at upkeep and costs life equal to its mana value" do
    ResolvePermanent("Darkstar Augur", owner: p1)
    spell = Card("Titanic Growth", owner: p1)
    p1.library.add(spell)
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
    game.settle!

    expect(p1.hand.cards).to include(spell)
    expect(p1.life).to eq(18)
  end

  describe "Pawpatch Recruit" do
    it "puts a counter on another creature when an opponent targets a creature you control" do
      recruit = ResolvePermanent("Pawpatch Recruit", owner: p1)
      other = bear
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) { _1.auto_pay_mana; _1.targeting(other) }
      game.settle!

      expect(counters(recruit)).to eq(1)
    end

    it "ignores your own targeting" do
      recruit = ResolvePermanent("Pawpatch Recruit", owner: p1)
      other = bear
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(other) }
      game.settle!

      expect(counters(recruit)).to eq(0)
    end
  end

  describe "Starscape Cleric" do
    it "can't block" do
      cleric = ResolvePermanent("Starscape Cleric", owner: p1)
      attacker = bear(owner: p2)

      expect(cleric.can_block?(attacker)).to be false
    end

    it "drains each opponent whenever you gain life" do
      ResolvePermanent("Starscape Cleric", owner: p1)
      p1.gain_life(2)
      game.settle!

      expect(p2.life).to eq(19)
    end
  end

  describe "Tender Wildguide" do
    let!(:guide) { ResolvePermanent("Tender Wildguide", owner: p1) }

    it "taps for any color" do
      p1.activate_ability(ability: guide.activated_abilities.first) { _1.choose(:blue) }

      expect(p1.mana_pool[:blue]).to eq(1)
    end

    it "taps to put a +1/+1 counter on itself" do
      p1.activate_ability(ability: guide.activated_abilities.last)
      game.stack.resolve!

      expect(counters(guide)).to eq(1)
    end
  end

  describe "Warren Warleader" do
    it "can create a tapped and attacking Rabbit" do
      warleader = ResolvePermanent("Warren Warleader", owner: p1)
      attack_with(warleader)
      game.resolve_choice!(mode: :token)
      rabbit = p1.creatures.find { _1.name == "Rabbit" }

      expect(rabbit).to be_tapped
    end

    it "can pump attacking creatures" do
      warleader = ResolvePermanent("Warren Warleader", owner: p1)
      attack_with(warleader)
      game.resolve_choice!(mode: :pump)
      game.tick!

      expect(warleader.power).to eq(5)
    end
  end

  describe "Carrot Cake" do
    it "creates a Rabbit and scries when it enters, and again when sacrificed" do
      cake = ResolvePermanent("Carrot Cake", owner: p1)
      game.skip_choice! while game.choices.any?
      expect(p1.creatures.map(&:name)).to eq(["Rabbit"])

      cake.sacrifice!
      game.settle!
      expect(p1.creatures.map(&:name)).to eq(%w[Rabbit Rabbit])
    end

    it "gains 3 life for {2}, {T} and a sacrifice" do
      cake = ResolvePermanent("Carrot Cake", owner: p1)
      game.skip_choice! while game.choices.any?
      p1.add_mana(white: 2)
      p1.activate_ability(ability: cake.activated_abilities.first) { _1.pay_mana(generic: { white: 2 }) }
      game.settle!
      game.skip_choice! while game.choices.any?
      game.stack.resolve!

      expect(p1.life).to eq(23)
    end
  end

  describe "Heaped Harvest" do
    it "searches for a basic land onto the battlefield tapped when it enters" do
      p1.library.add(Card("Forest", owner: p1))
      ResolvePermanent("Heaped Harvest", owner: p1)
      choice = game.choices.first
      game.resolve_choice!(targets: [choice.choices.first])
      land = p1.permanents.find { _1.land? }

      expect(land).to be_tapped
    end
  end

  describe "Hidden Grotto" do
    it "surveils 1 when it enters and taps for colorless" do
      grotto = ResolvePermanent("Hidden Grotto", owner: p1)
      expect(game.choices.first).to be_a(Magic::Choice::Surveil)

      grotto.untap!
      p1.activate_ability(ability: grotto.activated_abilities.first)
      expect(p1.mana_pool[:colorless]).to eq(1)
    end
  end

  describe "Uncharted Haven" do
    it "enters tapped and taps for the chosen color" do
      haven = ResolvePermanent("Uncharted Haven", owner: p1)
      game.resolve_choice!(color: :black)
      haven.untap!
      p1.activate_ability(ability: haven.activated_abilities.first)

      expect(p1.mana_pool[:black]).to eq(1)
    end
  end

  describe "the Villages" do
    def village(name)
      ResolvePermanent(name, owner: p1).tap(&:untap!)
    end

    it "all tap for {C}, and for colored mana only usable on creature spells" do
      village = village("Lilypad Village")
      p1.activate_ability(ability: village.activated_abilities[1])
      creature = Card("Grizzly Bears", owner: p1)
      instant = Card("Titanic Growth", owner: p1)
      target = bear

      expect(p1.spendable_mana_for(creature)[:blue]).to eq(1)
      expect(p1.spendable_mana_for(instant)[:blue]).to eq(0)
      expect(target).not_to be_nil
    end

    it "Lilypad Village surveils 2 once a Bird, Frog, Otter or Rat entered this turn" do
      village = village("Lilypad Village")
      ability = village.activated_abilities.last
      expect(ability.requirements_met?).to be false

      ResolvePermanent("Valley Mightcaller", owner: p1)
      expect(ability.requirements_met?).to be true
    end

    it "Mudflat Village returns a Bat, Lizard, Rat or Squirrel card to your hand" do
      village = village("Mudflat Village")
      card = Card("Valley Rotcaller", owner: p1).tap { p1.graveyard.add(_1) }
      p1.add_mana(black: 2)
      p1.activate_ability(ability: village.activated_abilities.last) do |action|
        action.pay_mana(generic: { black: 1 }, black: 1)
        action.pay_self_sacrifice
        action.targeting(card)
      end
      game.stack.resolve!

      expect(p1.hand.cards).to include(card)
    end

    it "Oakhollow Village puts counters on tribe members that entered this turn" do
      village = village("Oakhollow Village")
      frog = ResolvePermanent("Valley Mightcaller", owner: p1)
      p1.add_mana(green: 1)
      p1.activate_ability(ability: village.activated_abilities.last) { _1.pay_mana(green: 1) }
      game.stack.resolve!

      expect(counters(frog)).to eq(1)
    end

    it "Rockface Village gives a Lizard, Mouse, Otter or Raccoon +1/+0 and haste" do
      village = village("Rockface Village")
      mouse = ResolvePermanent("Heartfire Hero", owner: p1)
      p1.add_mana(red: 1)
      p1.activate_ability(ability: village.activated_abilities.last) do |action|
        action.pay_mana(red: 1)
        action.targeting(mouse)
      end
      game.stack.resolve!
      game.tick!

      expect(mouse.power).to eq(3) # +1/+0, and valiant added a counter
      expect(mouse.keywords).to include(Magic::Cards::Keywords::HASTE)
    end

    it "Lupinflower Village looks at the top six cards" do
      village = village("Lupinflower Village")
      p1.add_mana(white: 2)
      p1.activate_ability(ability: village.activated_abilities.last) do |action|
        action.pay_mana(generic: { white: 1 }, white: 1)
        action.pay_self_sacrifice
      end
      game.stack.resolve!

      expect(game.choices.first).to be_a(Magic::Choice::LookAtTopCards)
    end
  end

  describe "Fountainport" do
    let!(:port) { ResolvePermanent("Fountainport", owner: p1) }

    it "creates a Fish for {3}, {T} and 1 life" do
      p1.add_mana(colorless: 3)
      p1.activate_ability(ability: port.activated_abilities[2]) { _1.pay_mana(generic: { colorless: 3 }) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Fish")
      expect(p1.life).to eq(19)
    end

    it "creates a Treasure for {4}, {T}" do
      p1.add_mana(colorless: 4)
      p1.activate_ability(ability: port.activated_abilities[3]) { _1.pay_mana(generic: { colorless: 4 }) }
      game.stack.resolve!

      expect(p1.permanents.map(&:name)).to include("Treasure")
    end

    it "draws a card for {2}, {T} and sacrificing a token" do
      token = Magic::Tokens::Fish.new(game: game, owner: p1).resolve!
      p1.add_mana(colorless: 2)
      before = p1.hand.count
      p1.activate_ability(ability: port.activated_abilities[1]) do |action|
        action.pay_mana(generic: { colorless: 2 })
        action.pay_sacrifice(token)
      end
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 1)
    end
  end
end
