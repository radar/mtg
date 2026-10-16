# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExpandingOoze do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:ooze) { ResolvePermanent("Expanding Ooze", owner: p1) }

  def adapt
    p1.add_mana(black: 1, green: 1)
    p1.activate_ability(ability: ooze.activated_abilities.first) { |a| a.pay_mana(black: 1, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(ooze, target: p2)
    game.settle!
    current_turn.attackers_declared!
    game.tick!
  end

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 3/3 Ooze" do
    expect([ooze.power, ooze.toughness]).to eq([3, 3])
    expect(ooze.type?("Ooze")).to be(true)
  end

  context "{B}{G}: Adapt 1" do
    it "puts a +1/+1 counter on it if it has none and spends the mana" do
      adapt

      expect([ooze.power, ooze.toughness]).to eq([4, 4])
      expect(p1.mana_pool[:black]).to eq(0)
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      adapt

      expect([ooze.power, ooze.toughness]).to eq([4, 4])
    end

    it "cannot be activated without paying the mana" do
      p1.add_mana(black: 1)

      expect {
        p1.activate_ability(ability: ooze.activated_abilities.first) { |a| a.pay_mana(black: 1, green: 1) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect([ooze.power, ooze.toughness]).to eq([3, 3])
    end
  end

  context "when it attacks" do
    it "puts a +1/+1 counter on a target modified creature you control (itself, once adapted)" do
      adapt
      attack!

      expect(plus_counters(ooze)).to eq(2)
    end

    it "targets another modified creature you control" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_counter("+1/+1")
      attack!

      expect(plus_counters(bears)).to eq(2)
      expect(plus_counters(ooze)).to eq(0)
    end

    it "offers only the modified creatures when several are available" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_counter("+1/+1")
      elves = ResolvePermanent("Llanowar Elves", owner: p1)
      elves.add_counter("+1/+1")
      plain = ResolvePermanent("Llanowar Elves", owner: p1)
      attack!

      expect(game.choices.first.choices).to contain_exactly(bears, elves)
      expect(game.choices.first.choices).not_to include(plain)
      game.resolve_choice!(target: elves)
      game.settle!
      expect(plus_counters(elves)).to eq(2)
    end

    it "does nothing when no creature you control is modified" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      attack!

      expect(game.choices).to be_empty
      expect(plus_counters(ooze)).to eq(0)
    end

    it "cannot target an opponent's modified creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      theirs.add_counter("+1/+1")
      attack!

      expect(plus_counters(theirs)).to eq(1)
      expect(game.choices).to be_empty
    end
  end
end
