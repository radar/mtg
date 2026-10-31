# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FallOfCairAndros do
  include_context "two player game"

  let!(:fall) { ResolvePermanent("Fall Of Cair Andros", owner: p1) }

  def armies = p1.creatures.by_type("Army")

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  def bolt(target)
    card = Card("Lightning Bolt", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card:) { |a| a.pay_mana(red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
    game.stack.resolve!
    game.settle!
  end

  describe "excess noncombat damage to an opponent's creature" do
    it "amasses Orcs X where X is the excess damage" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2) # 2/2, Bolt deals 3

      bolt(bears)

      expect(armies.size).to eq(1)
      expect(counters(armies.first)).to eq(1)
      expect(armies.first.type?("Orc")).to eq(true)
    end

    it "adds to an existing Army" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      bolt(p2.creatures.first)
      bolt(ResolvePermanent("Grizzly Bears", owner: p2))

      expect(armies.size).to eq(1)
      expect(counters(armies.first)).to eq(2)
    end

    it "counts only damage beyond what was still lethal when the creature already has damage marked" do
      courser = ResolvePermanent("Courser Of Kruphix", owner: p2) # 2/4

      bolt(courser)
      expect(armies).to be_empty # 3 damage, none excess

      bolt(courser) # 1 more was lethal, so 2 excess
      expect(counters(armies.first)).to eq(2)
    end

    it "does nothing when the damage is not more than lethal" do
      courser = ResolvePermanent("Courser Of Kruphix", owner: p2)

      bolt(courser)

      expect(armies).to be_empty
    end
  end

  it "does not trigger for your own creatures" do
    bolt(ResolvePermanent("Grizzly Bears", owner: p1))

    expect(armies).to be_empty
  end

  it "does not trigger for damage dealt to a player" do
    bolt(p2)

    expect(armies).to be_empty
  end

  it "does not trigger for excess combat damage" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    attacker = ResolvePermanent("Alpine Grizzly", owner: p1) # 4 power into a 2/2 blocker
    go_to_main_phase!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: attacker)
    current_turn.combat_damage!
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(blocker.card.zone).to be_graveyard
    expect(armies).to be_empty
  end

  describe "{7}{R}: deals 7 damage to target creature" do
    def activate(target)
      p1.add_mana(red: 8)
      p1.activate_ability(ability: fall.activated_abilities.first) do
        _1.pay_mana(red: 1, generic: { red: 7 })
        _1.targeting(target)
      end
      game.stack.resolve!
      game.settle!
      game.stack.resolve!
      game.settle!
    end

    it "deals 7 damage to the creature, and the excess is amassed when it is an opponent's" do
      courser = ResolvePermanent("Courser Of Kruphix", owner: p2) # toughness 4

      activate(courser)

      expect(courser.card.zone).to be_graveyard
      expect(counters(armies.first)).to eq(3)
    end

    it "can target your own creature without amassing" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)

      activate(bears)

      expect(bears.card.zone).to be_graveyard
      expect(armies).to be_empty
    end
  end
end
