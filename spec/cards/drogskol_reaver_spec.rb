# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DrogskolReaver do
  include_context "two player game"

  let!(:reaver) { ResolvePermanent("Drogskol Reaver", owner: p1) }

  it "is a 3/5 flying, double strike, lifelink Spirit" do
    expect([reaver.power, reaver.toughness]).to eq([3, 5])
    expect(reaver).to be_flying
    expect(reaver).to be_double_strike
    expect(reaver).to be_lifelink
  end

  it "draws a card whenever you gain life" do
    hand_size = p1.hand.count
    p1.gain_life(2)
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "doesn't draw when an opponent gains life" do
    hand_size = p1.hand.count
    p2.gain_life(2)
    game.settle!

    expect(p1.hand.count).to eq(hand_size)
  end
end
