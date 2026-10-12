# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ViciousClown do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:clown) { ResolvePermanent("Vicious Clown", owner: p1) }

  it "is a 2/3" do
    expect(clown.power).to eq(2)
    expect(clown.toughness).to eq(3)
  end

  it "gets +2/+0 when another creature with power 2 or less enters under your control" do
    ResolvePermanent("Wood Elves", owner: p1)
    game.settle!
    game.tick!
    expect(clown.power).to eq(4)
    expect(clown.toughness).to eq(3)
  end

  it "does not trigger for a creature with power 3 or more" do
    ResolvePermanent("Terror Of The Peaks", owner: p1)
    game.settle!
    expect(clown.power).to eq(2)
  end

  it "does not trigger for an opponent's creature" do
    ResolvePermanent("Wood Elves", owner: p2)
    game.settle!
    expect(clown.power).to eq(2)
  end

  it "wears off at end of turn" do
    ResolvePermanent("Wood Elves", owner: p1)
    game.settle!
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(clown.power).to eq(2)
  end
end
