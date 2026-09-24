# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated blight in play" do
  include CardParserHelpers
  include_context "two player game"

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  describe "\"you may blight N. If you do, ...\"" do
    before do
      load_card("Parsed Seizer {3}{B}\nCreature — Faerie\nWhen ~ enters, you may blight 1. If you do, each opponent discards a card.\n3/4\n")
    end

    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "puts a -1/-1 counter on a creature you choose, then runs the rest" do
      seizer = ResolvePermanent("Parsed Seizer", owner: p1)
      game.resolve_choice!
      expect(game.choices.last).to be_a(Magic::Choice::Blight)
      expect(game.choices.last.choices).to contain_exactly(bears, seizer)

      game.resolve_choice!(target: bears)
      expect(minus_counters(bears)).to eq(1)
      expect(game.choices.last).to be_a(Magic::Choice::Discard)
      expect(game.choices.last.player).to eq(p2)
    end

    it "does nothing when declined" do
      ResolvePermanent("Parsed Seizer", owner: p1)
      game.skip_choice!
      expect(minus_counters(bears)).to eq(0)
      expect(game.choices).to be_empty
    end

    it "does nothing if you control no creature to blight" do
      load_card("Parsed Mischief {2}{B}\nEnchantment\nWhen ~ enters, you may blight 1. If you do, you gain 5 life.\n")
      ResolvePermanent("Parsed Mischief", owner: p1)
      bears.destroy!
      game.settle!
      game.choices.clear
      ResolvePermanent("Parsed Mischief", owner: p1)
      game.resolve_choice!
      expect(game.choices).to be_empty
      expect(p1.life).to eq(20)
    end
  end

  describe "\"you may blight N. If you don't, ...\"" do
    before do
      load_card("Parsed Gang {3}{B}\nCreature — Goblin\nAt the beginning of your first main phase, you may blight 2. If you don't, you lose 3 life.\n6/6\n")
    end

    let!(:gang) { ResolvePermanent("Parsed Gang", owner: p1) }

    it "loses 3 life when declined" do
      go_to_main_phase!
      game.skip_choice!
      expect(p1.life).to eq(17)
      expect(minus_counters(gang)).to eq(0)
    end

    it "puts two -1/-1 counters on the creature when accepted, and doesn't lose life" do
      go_to_main_phase!
      game.resolve_choice!
      game.resolve_choice!(target: gang)
      expect(minus_counters(gang)).to eq(2)
      expect(p1.life).to eq(20)
    end
  end

  it "blights when a trigger says so, without asking" do
    load_card("Parsed Urchin {2}{B}\nCreature — Ouphe\nWhenever ~ attacks, blight 1.\n3/4\n")
    urchin = ResolvePermanent("Parsed Urchin", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: urchin, target: p2)
    current_turn.attackers_declared!
    game.resolve_choice!(target: urchin)
    expect(minus_counters(urchin)).to eq(1)
  end

  it "makes each opponent blight" do
    load_card("Parsed Morcant {2}{B}{G}\nCreature — Elf\nWhen ~ enters, each opponent blights 2.\n4/4\n")
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Parsed Morcant", owner: p1)
    choice = game.choices.last
    expect(choice.player).to eq(p2)
    game.resolve_choice!(target: theirs)
    expect(minus_counters(theirs)).to eq(2)
  end

  describe "blight as an activation cost" do
    before do
      load_card("Parsed Slinger {2}{R}\nCreature — Goblin\n{1}{R}, {T}, Blight 1: ~ deals 2 damage to each opponent.\n3/3\n")
    end

    let!(:slinger) { ResolvePermanent("Parsed Slinger", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "puts the counter on the creature you pay with" do
      p1.add_mana(red: 2)
      p1.activate_ability(ability: slinger.activated_abilities.first) do
        _1.pay_mana(generic: { red: 1 }, red: 1)
        _1.pay_blight(bears)
      end
      game.stack.resolve!

      expect(minus_counters(bears)).to eq(1)
      expect(p2.life).to eq(18)
    end

    it "can't blight a creature an opponent controls" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(red: 2)
      expect do
        p1.activate_ability(ability: slinger.activated_abilities.first) do
          _1.pay_mana(generic: { red: 1 }, red: 1)
          _1.pay_blight(theirs)
        end
      end.to raise_error(/Invalid creature chosen to blight/)
    end

    it "must be paid" do
      p1.add_mana(red: 2)
      expect do
        p1.activate_ability(ability: slinger.activated_abilities.first) do
          _1.pay_mana(generic: { red: 1 }, red: 1)
        end
      end.to raise_error(/Blight 1 has not been paid/)
    end
  end
end
