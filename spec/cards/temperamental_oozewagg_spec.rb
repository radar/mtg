# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TemperamentalOozewagg do
  include_context "two player game"

  let!(:oozewagg) { ResolvePermanent("Temperamental Oozewagg", owner: p1) }

  def adapt
    p1.add_mana(green: 3)
    p1.activate_ability(ability: oozewagg.activated_abilities.first) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/4 Ooze Brushwagg" do
    expect([oozewagg.power, oozewagg.toughness]).to eq([4, 4])
    expect(oozewagg.type?("Brushwagg")).to be(true)
  end

  context "Adapt 2" do
    it "puts two +1/+1 counters on it if it has none" do
      adapt

      expect([oozewagg.power, oozewagg.toughness]).to eq([6, 6])
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      adapt

      expect([oozewagg.power, oozewagg.toughness]).to eq([6, 6])
    end

    it "can be activated again after the counters are gone" do
      adapt
      oozewagg.take_counters!(Magic::Counters::Plus1Plus1, amount: 2)
      adapt

      expect([oozewagg.power, oozewagg.toughness]).to eq([6, 6])
    end
  end

  context "Modified creatures you control have trample" do
    it "gives trample to a modified creature, including itself" do
      adapt
      game.tick!

      expect(oozewagg).to have_keyword(:trample)
    end

    it "gives trample to another modified creature you control" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_counter("+1/+1")
      game.tick!

      expect(bears).to have_keyword(:trample)
    end

    it "does not give trample to unmodified creatures or an opponent's modified creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      theirs.add_counter("+1/+1")
      game.tick!

      expect(bears).not_to have_keyword(:trample)
      expect(theirs).not_to have_keyword(:trample)
      expect(oozewagg).not_to have_keyword(:trample)
    end
  end
end
