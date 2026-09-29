# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoldwyrAggressor do
  include_context "two player game"

  let!(:aggressor) { ResolvePermanent("Boldwyr Aggressor", owner: p1) }

  it "is a 2/5 with double strike" do
    expect([aggressor.power, aggressor.toughness]).to eq([2, 5])
    expect(aggressor).to be_double_strike
  end

  it "gives another Giant you control double strike" do
    giant = ResolvePermanent("Hill Giant Herdgorger", owner: p1)
    game.tick!
    expect(giant).to be_double_strike
  end

  it "doesn't give it to other creatures or to an opponent's Giants" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    rival = ResolvePermanent("Hill Giant Herdgorger", owner: p2)
    game.tick!

    expect(bears).not_to be_double_strike
    expect(rival).not_to be_double_strike
  end

  it "stops granting it when it leaves the battlefield" do
    giant = ResolvePermanent("Hill Giant Herdgorger", owner: p1)
    game.tick!
    aggressor.destroy!
    game.tick!

    expect(giant).not_to be_double_strike
  end
end
