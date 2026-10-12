# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ValgavothHarrowerOfSouls do
  include_context "two player game"

  let!(:valgavoth) { ResolvePermanent("Valgavoth Harrower Of Souls", owner: p1) }

  def counters = valgavoth.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 4/4 flyer with ward--pay 2 life" do
    expect(valgavoth).to have_keyword(:flying)
    expect([valgavoth.power, valgavoth.toughness]).to eq([4, 4])
  end

  context "during the opponent's turn" do
    before { go_to_main_phase_for!(p2) }

    it "gets a counter and draws a card the first time the opponent loses life" do
      hand = p1.hand.cards.count
      p2.lose_life(1)
      game.settle!

      expect(counters).to eq(1)
      expect(p1.hand.cards.count).to eq(hand + 1)
    end

    it "only triggers the first time each turn" do
      p2.lose_life(1)
      game.settle!
      p2.lose_life(1)
      game.settle!

      expect(counters).to eq(1)
    end
  end

  it "ignores life lost on your own turn" do
    go_to_main_phase!
    p2.lose_life(1)
    game.settle!

    expect(counters).to eq(0)
  end

  it "ignores its controller losing life" do
    go_to_main_phase_for!(p2)
    p1.lose_life(1)
    game.settle!

    expect(counters).to eq(0)
  end
end
