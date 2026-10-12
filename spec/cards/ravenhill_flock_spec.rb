# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RavenhillFlock do
  include_context "two player game"

  let!(:flock) { ResolvePermanent("Ravenhill Flock", owner: p1) }

  it "is a 1/2 flyer" do
    expect([flock.power, flock.toughness]).to eq([1, 2])
    expect(flock).to be_flying
  end

  it "gets a +1/+1 counter whenever you draw a card" do
    p1.draw!
    game.settle!

    expect([flock.power, flock.toughness]).to eq([2, 3])
  end

  it "doesn't grow when an opponent draws" do
    p2.draw!
    game.settle!

    expect([flock.power, flock.toughness]).to eq([1, 2])
  end
end
