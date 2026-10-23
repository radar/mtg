# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NyxbornHydra do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Nyxborn Hydra", owner: p1) }

  it "enters with X +1/+1 counters, with reach and trample" do
    p1.add_mana(green: 4)
    p1.cast(card:, value_for_x: 3) { |a| a.pay_mana(x: { green: 3 }, green: 1) }
    game.stack.resolve!
    game.settle!
    game.tick!

    hydra = p1.creatures.find { _1.name == "Nyxborn Hydra" }
    expect([hydra.power, hydra.toughness]).to eq([3, 4])
    expect(hydra.reach?).to eq(true)
    expect(hydra.trample?).to eq(true)
  end

  context "when bestowed" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      p1.add_mana(green: 5)
      p1.cast_as(:bestowed, card:, value_for_x: 2) { |a| a.pay_mana(x: { green: 2 }, green: 2).targeting(bears) }
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "gives the creature +1/+1 per counter, reach and trample" do
      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect(bears.reach?).to eq(true)
      expect(bears.trample?).to eq(true)
    end
  end
end
