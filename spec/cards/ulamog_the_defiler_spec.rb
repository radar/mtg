# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UlamogTheDefiler do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Ulamog The Defiler", owner: p1) }

  def cast_ulamog
    p1.hand.add(card)
    p1.add_mana(colorless: 10)
    p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 10 }) }
    game.settle!
    game.stack.resolve!
    game.settle!
  end

  def attack(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a legendary 7/7 Eldrazi" do
    ulamog = ResolvePermanent("Ulamog The Defiler", owner: p1)

    expect([ulamog.power, ulamog.toughness]).to eq([7, 7])
    expect(ulamog.type?("Eldrazi")).to eq(true)
    expect(ulamog.legendary?).to eq(true)
  end

  describe "when cast" do
    it "makes the opponent exile the top half of their library, rounded up" do
      p2.library.cards.shift while p2.library.cards.size > 6
      size = p2.library.cards.size
      expected = (size + 1) / 2
      top = p2.library.cards.first(expected)

      cast_ulamog

      expect(p2.library.cards.size).to eq(size - expected)
      expect(top.map(&:zone)).to all(be_exile)
    end

    it "rounds up with an odd-sized library" do
      p2.library.cards.shift while p2.library.cards.size > 5
      cast_ulamog

      expect(p2.library.cards.size).to eq(2)
    end

    it "does not affect your own library" do
      size = p1.library.cards.size
      cast_ulamog

      expect(p1.library.cards.size).to eq(size)
    end
  end

  describe "enters with +1/+1 counters equal to the greatest mana value in exile" do
    it "counts cards exiled by its own cast trigger and others" do
      big = Card("Serra Angel", owner: p2)
      game.exile.add(big)
      cast_ulamog
      ulamog = p1.creatures.find { _1.name == "Ulamog, the Defiler" }
      greatest = game.exile.cards.map(&:mana_value).max

      expect(greatest).to be >= 5
      expect(ulamog.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(greatest)
      expect(ulamog.power).to eq(7 + greatest)
    end

    it "enters with no counters when exile holds only mana value 0 cards" do
      p2.library.cards.clear
      cast_ulamog
      ulamog = p1.creatures.find { _1.name == "Ulamog, the Defiler" }

      expect(ulamog.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
    end
  end

  describe "annihilator X" do
    it "makes the defending player sacrifice a number of permanents equal to its +1/+1 counters" do
      ulamog = ResolvePermanent("Ulamog The Defiler", owner: p1)
      ulamog.add_counter(Magic::Counters::Plus1Plus1, amount: 2)
      4.times { ResolvePermanent("Grizzly Bears", owner: p2) }

      attack(ulamog)
      game.skip_choice!
      game.settle!

      expect(p2.permanents.size).to eq(2)
    end

    it "uses the X recorded when it attacked, even if the counters change while the trigger is on the stack (113.7a)" do
      ulamog = ResolvePermanent("Ulamog The Defiler", owner: p1)
      ulamog.add_counter(Magic::Counters::Plus1Plus1, amount: 2)
      4.times { ResolvePermanent("Grizzly Bears", owner: p2) }

      game.notify!(Magic::Events::CreatureAttacked.new(attacker: ulamog, target: p2))

      # The trigger has fired (X recorded) but has not resolved yet.
      expect(game.pending_triggers.size).to eq(1)
      ulamog.add_counter(Magic::Counters::Plus1Plus1, amount: 3)
      expect(ulamog.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(5)

      game.settle!
      expect(game.choices.size).to eq(1)
      expect(game.choices.first.amount).to eq(2)
      game.skip_choice!
      game.settle!

      expect(p2.permanents.size).to eq(2)
    end

    it "also triggers separately for a separately granted annihilator" do
      ulamog = ResolvePermanent("Ulamog The Defiler", owner: p1)
      ulamog.add_counter(Magic::Counters::Plus1Plus1, amount: 2)
      ulamog.grant_keyword(Magic::Cards::Keywords::Annihilator.new(1))
      6.times { ResolvePermanent("Grizzly Bears", owner: p2) }

      attack(ulamog)
      amounts = []
      while (choice = game.choices.first)
        amounts << choice.amount
        game.skip_choice!
        game.settle!
      end

      expect(amounts.sort).to eq([1, 2])
      expect(p2.permanents.size).to eq(3)
    end

    it "does nothing without counters" do
      ulamog = ResolvePermanent("Ulamog The Defiler", owner: p1)
      2.times { ResolvePermanent("Grizzly Bears", owner: p2) }

      attack(ulamog)

      expect(game.choices).to be_empty
      expect(p2.permanents.size).to eq(2)
    end
  end

  describe "ward--sacrifice two permanents" do
    let!(:ulamog) { ResolvePermanent("Ulamog The Defiler", owner: p1) }
    let(:spell) { Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) } }

    before do
      game.next_turn
      go_to_main_phase!
      p2.add_mana(red: 1)
      p2.cast(card: spell) { _1.pay_mana(red: 1).targeting(ulamog) }
      game.settle!
    end

    it "counters the spell if they don't sacrifice" do
      ward = game.choices.last
      expect(ward).to be_a(Magic::Choice::Ward)
      expect(ward.sacrifice_any).to eq(2)
      game.resolve_choice!(sacrifices: [])
      game.stack.resolve!

      expect(ulamog.damage).to eq(0)
    end

    it "lets the spell resolve when they sacrifice two permanents" do
      two = 2.times.map { ResolvePermanent("Forest", owner: p2) }
      game.resolve_choice!(sacrifices: two)

      expect(two.map(&:zone)).to all(be_nil)
      game.stack.resolve!
      expect(ulamog.damage).to eq(3)
    end

    it "does not accept one permanent" do
      one = ResolvePermanent("Forest", owner: p2)
      game.resolve_choice!(sacrifices: [one])

      expect(one.zone).to be_battlefield
      game.stack.resolve!
      expect(ulamog.damage).to eq(0)
    end
  end
end
