# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Attercop do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:attercop) { ResolvePermanent("Attercop", owner: p1) }

  it "is a 2/1 with reach and deathtouch" do
    expect([attercop.power, attercop.toughness]).to eq([2, 1])
    expect(attercop.reach?).to be(true)
    expect(attercop.deathtouch?).to be(true)
  end

  it "gets +1/+1 until end of turn when a land enters under your control" do
    p1.play_land(land: Card("Mountain", owner: p1))
    game.settle!
    game.tick!

    expect([attercop.power, attercop.toughness]).to eq([3, 2])
  end

  it "wears off at end of turn" do
    p1.play_land(land: Card("Mountain", owner: p1))
    game.settle!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([attercop.power, attercop.toughness]).to eq([2, 1])
  end

  it "ignores an opponent's land" do
    ResolvePermanent("Mountain", owner: p2)
    game.settle!
    game.tick!

    expect([attercop.power, attercop.toughness]).to eq([2, 1])
  end
end
