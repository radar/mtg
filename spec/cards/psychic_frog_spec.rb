# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PsychicFrog do
  include_context "two player game"

  let!(:frog) { ResolvePermanent("Psychic Frog", owner: p1) }

  def attack(target)
    go_to_main_phase!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(frog, target: target)
    current_turn.attackers_declared!
  end

  it "is a 1/2 Frog" do
    expect([frog.power, frog.toughness]).to eq([1, 2])
    expect(frog.type?("Frog")).to be(true)
  end

  describe "combat damage trigger" do
    it "draws a card when it deals combat damage to a player" do
      attack(p2)
      hand_size = p1.hand.count
      go_to_combat_damage!
      game.settle!

      expect(p2.life).to eq(19)
      expect(p1.hand.count).to eq(hand_size + 1)
    end

    it "draws a card when it deals combat damage to a planeswalker" do
      walker = ResolvePermanent("Ajani, Outland Chaperone", owner: p2)
      attack(walker)
      hand_size = p1.hand.count
      go_to_combat_damage!
      game.settle!

      expect(p1.hand.count).to eq(hand_size + 1)
    end

    it "doesn't draw when it deals combat damage to a creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      hand_size = p1.hand.count
      game.notify!(Magic::Events::CombatDamageDealt.new(source: frog, target: bears, damage: 1))
      game.settle!

      expect(p1.hand.count).to eq(hand_size)
    end

    it "doesn't draw when another creature deals combat damage to a player" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      hand_size = p1.hand.count
      game.notify!(Magic::Events::CombatDamageDealt.new(source: bears, target: p2, damage: 2))
      game.settle!

      expect(p1.hand.count).to eq(hand_size)
    end
  end

  describe "discard a card: +1/+1 counter" do
    let(:ability) { frog.activated_abilities.first }

    it "discards a card to put a +1/+1 counter on it" do
      card = p1.hand.cards.first
      p1.activate_ability(ability: ability) { |action| action.pay_discard(card) }
      game.stack.resolve!
      game.settle!

      expect(p1.graveyard.cards).to include(card)
      expect([frog.power, frog.toughness]).to eq([2, 3])
    end

    it "can be activated repeatedly" do
      2.times do
        card = p1.hand.cards.first
        p1.activate_ability(ability: ability) { |action| action.pay_discard(card) }
        game.stack.resolve!
      end
      game.settle!

      expect([frog.power, frog.toughness]).to eq([3, 4])
    end

    it "can't be activated by the opponent" do
      expect { p2.activate_ability(ability: ability) { |action| action } }.to raise_error(Magic::IllegalAction, /does not control/)
      expect(frog.counters).to be_empty
    end
  end

  describe "exile three cards from your graveyard: flying" do
    let(:ability) { frog.activated_abilities.last }
    let!(:graveyard_cards) { 3.times.map { Card("Island", owner: p1).tap { p1.graveyard.add(_1) } } }

    it "gains flying until end of turn" do
      expect(frog).not_to have_keyword(:flying)

      p1.activate_ability(ability: ability) { |action| action.pay_exile_from_graveyard(graveyard_cards) }
      game.stack.resolve!
      game.tick!

      expect(frog).to have_keyword(:flying)
      expect(p1.graveyard.cards).to be_empty
      expect(game.exile.cards).to include(*graveyard_cards)

      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(frog).not_to have_keyword(:flying)
    end

    it "can't be paid with fewer than three cards" do
      expect {
        p1.activate_ability(ability: ability) { |action| action.pay_exile_from_graveyard(graveyard_cards.first(2)) }
      }.to raise_error(ArgumentError, /exile exactly 3/)
    end

    it "can't be activated by the opponent" do
      expect { p2.activate_ability(ability: ability) { |action| action } }.to raise_error(Magic::IllegalAction, /does not control/)
      expect(p1.graveyard.cards.size).to eq(3)
    end
  end
end
