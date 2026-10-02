# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ClinquantSkymage do
  include_context "two player game"

  let!(:skymage) { ResolvePermanent("Clinquant Skymage", owner: p1) }

  it "is a 1/1 flyer" do
    expect([skymage.power, skymage.toughness]).to eq([1, 1])
    expect(skymage).to be_flying
  end

  it "gets a +1/+1 counter whenever you draw a card" do
    p1.draw!
    game.settle!
    game.tick!

    expect([skymage.power, skymage.toughness]).to eq([2, 2])
  end

  it "doesn't get a counter when an opponent draws" do
    p2.draw!
    game.settle!
    game.tick!

    expect(skymage.power).to eq(1)
  end
end
