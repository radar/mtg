# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OnduKnotmaster do
  include_context "two player game"

  let(:card) { Card("Ondu Knotmaster", owner: p1) }

  before { go_to_main_phase! }

  def plus_one_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 2/2 lifelink Kor Rogue" do
    knotmaster = ResolvePermanent("Ondu Knotmaster", owner: p1)

    expect([knotmaster.power, knotmaster.toughness]).to eq([2, 2])
    expect(knotmaster.has_keyword?(Magic::Cards::Keywords::LIFELINK)).to eq(true)
  end

  describe "Throw a Line" do
    before { p1.hand.add(card) }

    it "puts both counters on a single target" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.add_mana(white: 1, black: 1)
      p1.cast_as(:adventure, card:) { _1.pay_mana(white: 1, black: 1).targeting(bears) }
      game.stack.resolve!

      expect(plus_one_counters(bears)).to eq(2)
      expect(card.on_adventure).to eq(true)
    end

    it "splits the counters between two targets" do
      one = ResolvePermanent("Grizzly Bears", owner: p1)
      two = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(white: 1, black: 1)
      p1.cast_as(:adventure, card:) { _1.pay_mana(white: 1, black: 1).targeting(one, two) }
      game.stack.resolve!

      expect([plus_one_counters(one), plus_one_counters(two)]).to eq([1, 1])
    end
  end

  describe "modified creature trigger" do
    let!(:knotmaster) { ResolvePermanent("Ondu Knotmaster", owner: p1) }

    it "puts two +1/+1 counters on it when another modified creature you control dies" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_counter(Magic::Counters::Plus1Plus1)
      bears.destroy!
      game.settle!

      expect(plus_one_counters(knotmaster)).to eq(2)
    end

    it "ignores an unmodified creature dying" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.destroy!
      game.settle!

      expect(plus_one_counters(knotmaster)).to eq(0)
    end

    it "ignores an opponent's modified creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bears.add_counter(Magic::Counters::Plus1Plus1)
      bears.destroy!
      game.settle!

      expect(plus_one_counters(knotmaster)).to eq(0)
    end
  end
end
