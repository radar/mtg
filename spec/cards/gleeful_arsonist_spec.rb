# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GleefulArsonist do
  include_context "two player game"

  let!(:arsonist) { ResolvePermanent("Gleeful Arsonist", owner: p1) }

  def arsonist_on_battlefield = p1.creatures.find { _1.name == "Gleeful Arsonist" }

  it "deals damage equal to its power when an opponent casts a noncreature spell" do
    go_to_main_phase_for!(p2)
    spell = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
    p2.add_mana(red: 1)
    p2.cast(card: spell) { _1.pay_mana(red: 1).targeting(p1) }
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "ignores an opponent's creature spell" do
    go_to_main_phase_for!(p2)
    bears = Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) }
    p2.add_mana(green: 2)
    p2.cast(card: bears) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "ignores its controller's own noncreature spells" do
    go_to_main_phase!
    spell = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(red: 1)
    p1.cast(card: spell) { _1.pay_mana(red: 1).targeting(p2) }
    game.settle!

    expect(p1.life).to eq(20)
  end

  describe "undying" do
    it "returns with a +1/+1 counter the first time it dies" do
      arsonist.destroy!
      game.settle!

      returned = arsonist_on_battlefield
      expect(returned).not_to be_nil
      expect(returned.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
      expect([returned.power, returned.toughness]).to eq([2, 3])
    end

    it "doesn't return a second time" do
      arsonist.destroy!
      game.settle!
      arsonist_on_battlefield.destroy!
      game.settle!

      expect(arsonist_on_battlefield).to be_nil
      expect(p1.graveyard.cards.map(&:name)).to include("Gleeful Arsonist")
    end
  end
end
