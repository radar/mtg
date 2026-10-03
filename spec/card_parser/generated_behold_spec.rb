# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated behold in play" do
  include CardParserHelpers
  include_context "two player game"

  before do
    load_card("Parsed Wyrm {3}{R}\nCreature — Dragon\nFlying\n3/3\n")
    go_to_main_phase!
  end

  let(:wyrm) { Card("Parsed Wyrm", owner: p1) }

  def hand_wyrm
    wyrm.tap { p1.hand.add(_1) }
  end

  describe "\"behold a Dragon or pay {1}\" as an additional cost" do
    before { load_card("Parsed Exhale {B}\nInstant\nAs an additional cost to cast this spell, behold a Dragon or pay {1}.\nTarget creature gets -3/-3 until end of turn.\n") }

    let(:spell) { Card("Parsed Exhale", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "is paid by beholding a Dragon on the battlefield" do
      dragon = ResolvePermanent("Parsed Wyrm", owner: p1)
      p1.add_mana(black: 1)
      p1.cast(card: spell) { |a| a.pay_mana(black: 1).pay_behold(dragon).targeting(bears) }
      game.stack.resolve!
      game.tick!
      expect(bears.toughness).to eq(-1)
    end

    it "is paid by revealing a Dragon from your hand" do
      card = hand_wyrm
      p1.add_mana(black: 1)
      p1.cast(card: spell) { |a| a.pay_mana(black: 1).pay_behold(card).targeting(bears) }
      expect(game.stack.spells.map(&:card)).to eq([spell])
      expect(p1.hand.cards).to include(card)
    end

    it "is paid with {1} instead" do
      p1.add_mana(black: 2)
      p1.cast(card: spell) { |a| a.pay_mana(black: 1).pay_behold(generic: { black: 1 }).targeting(bears) }
      game.stack.resolve!
      game.tick!
      expect(bears.toughness).to eq(-1)
    end

    it "can't be cast without paying it" do
      p1.add_mana(black: 1)
      expect { p1.cast(card: spell) { |a| a.pay_mana(black: 1).targeting(bears) } }.to raise_error(/Additional costs have not been paid/)
    end

    it "can't behold a non-Dragon" do
      p1.add_mana(black: 1)
      expect { p1.cast(card: spell) { |a| a.pay_mana(black: 1).pay_behold(ResolvePermanent("Grizzly Bears", owner: p1)) } }.to raise_error(/can't be beheld/)
    end
  end

  describe "\"you may behold a Dragon\" and \"If a Dragon was beheld, ...\"" do
    before do
      load_card("Parsed Breath {1}{W}\nInstant\nAs an additional cost to cast this spell, you may behold a Dragon.\n~ deals 5 damage to target attacking or blocking creature. If a Dragon was beheld, you gain 2 life.\n")
    end

    let(:spell) { Card("Parsed Breath", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    def attack_with_bears!
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      game.next_turn
      skip_to_combat!
      current_turn.declare_attackers!
      p2.declare_attacker(attacker: bears, target: p1)
    end

    it "gains 2 life when a Dragon was beheld" do
      dragon = ResolvePermanent("Parsed Wyrm", owner: p1)
      p1.add_mana(white: 2)
      attack_with_bears!
      p1.cast(card: spell) { |a| a.pay_mana(generic: { white: 1 }, white: 1).pay_kicker(dragon).targeting(bears) }
      game.stack.resolve!
      expect(p1.life).to eq(22)
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "doesn't gain life when nothing was beheld, and forgets the behold for the next cast" do
      dragon = ResolvePermanent("Parsed Wyrm", owner: p1)
      p1.add_mana(white: 2)
      attack_with_bears!
      p1.cast(card: spell) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
      game.stack.resolve!
      expect(p1.life).to eq(20)
      expect(spell.kicker_cost).not_to be_paid
      expect(dragon.zone).to be_battlefield
    end

    it "can only behold a Dragon" do
      p1.add_mana(white: 2)
      expect { p1.cast(card: spell) { |a| a.pay_kicker(ResolvePermanent("Grizzly Bears", owner: p1)) } }.to raise_error(/can't be beheld/)
    end
  end

  describe "\"You may cast this spell as though it had flash if you behold a Dragon\"" do
    before do
      load_card("Parsed Exhale Of Flame {1}{R}\nSorcery\nYou may cast ~ as though it had flash if you behold a Dragon as an additional cost to cast it.\n~ deals 4 damage to target creature or planeswalker.\n")
    end

    let(:spell) { Card("Parsed Exhale Of Flame", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "is a sorcery without a Dragon" do
      go_to_main_phase_for!(p2)
      p1.add_mana(red: 2)
      expect { p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) } }.to raise_error(Magic::IllegalAction)
    end

    it "can be cast on an opponent's turn when you behold a Dragon" do
      dragon = ResolvePermanent("Parsed Wyrm", owner: p1)
      go_to_main_phase_for!(p2)
      p1.add_mana(red: 2)
      p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 1 }, red: 1).pay_kicker(dragon).targeting(bears) }
      game.stack.resolve!
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "\"you may behold a Dragon. If you do, ...\" on an enters trigger" do
    before do
      load_card("Parsed Druid {1}{R}\nCreature — Human Druid\nWhen ~ enters, you may behold a Dragon. If you do, create a Treasure token.\n2/2\n")
    end

    it "creates a Treasure when you behold a Dragon from your hand" do
      hand_wyrm
      ResolvePermanent("Parsed Druid", owner: p1)
      expect(game.choices.last).to be_a(Magic::Choice::Behold)
      game.resolve_choice!
      expect(p1.permanents.count { _1.name == "Treasure" }).to eq(1)
    end

    it "does nothing when declined" do
      hand_wyrm
      ResolvePermanent("Parsed Druid", owner: p1)
      game.skip_choice!
      expect(p1.permanents.count { _1.name == "Treasure" }).to eq(0)
    end

    it "doesn't ask when there is no Dragon to behold" do
      ResolvePermanent("Parsed Druid", owner: p1)
      expect(game.choices).to be_empty
    end
  end

  describe "\"Whenever a Dragon you control enters\" and becoming a Dragon" do
    before do
      load_card("Parsed Ascendant {1}{R}\nCreature — Human Druid\nWhenever a Dragon you control enters, put a +1/+1 counter on ~. Until end of turn, ~ becomes a Dragon in addition to its other types and gains flying.\n2/2\n")
    end

    let!(:ascendant) { ResolvePermanent("Parsed Ascendant", owner: p1) }

    it "puts a counter on it and makes it a flying Dragon until end of turn" do
      ResolvePermanent("Parsed Wyrm", owner: p1)
      game.tick!
      expect(ascendant.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
      expect(ascendant.type?("Dragon")).to be(true)
      expect(ascendant.keywords).to include(Magic::Cards::Keywords::FLYING)
      current_turn.end!
      current_turn.cleanup!
      game.tick!
      expect(ascendant.type?("Dragon")).to be(false)
    end

    it "ignores a non-Dragon" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!
      expect(ascendant.type?("Dragon")).to be(false)
    end
  end

  describe "\"Target creature you control deals damage equal to its power to target creature or planeswalker\"" do
    before { load_card("Parsed Bite {1}{G}\nInstant\nTarget creature you control deals damage equal to its power to target creature or planeswalker.\n") }

    let(:spell) { Card("Parsed Bite", owner: p1) }
    let!(:wyrm_on_field) { ResolvePermanent("Parsed Wyrm", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "deals damage one way" do
      p1.add_mana(green: 2)
      p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(wyrm_on_field, bears) }
      game.stack.resolve!
      game.tick!
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(wyrm_on_field.damage).to eq(0)
    end

    it "must start with a creature you control" do
      p1.add_mana(green: 2)
      expect { p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(bears, wyrm_on_field) } }
        .to raise_error(Magic::Actions::Cast::InvalidTarget)
    end

    it "does nothing if its creature left the battlefield" do
      p1.add_mana(green: 2)
      p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(wyrm_on_field, bears) }
      wyrm_on_field.destroy!
      game.stack.resolve!
      expect(bears.zone).to be_battlefield
    end
  end
end
