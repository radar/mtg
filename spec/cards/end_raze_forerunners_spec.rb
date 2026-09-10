# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EndRazeForerunners do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:opponent_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  subject!(:forerunners) { ResolvePermanent("End-Raze Forerunners", owner: p1) }

  before { game.tick! }

  it "is a 7/7 Boar with vigilance, trample, and haste" do
    expect(forerunners.power).to eq(7)
    expect(forerunners.toughness).to eq(7)
    expect(forerunners).to be_vigilant
    expect(forerunners).to be_trample
    expect(forerunners.has_keyword?(:haste)).to eq(true)
  end

  it "gives other creatures you control +2/+2, vigilance, and trample until end of turn" do
    expect(wood_elves.power).to eq(3)
    expect(wood_elves.toughness).to eq(3)
    expect(wood_elves).to be_vigilant
    expect(wood_elves).to be_trample
    expect(wood_elves.has_keyword?(:haste)).to eq(false)
  end

  it "does not buff itself or opponents' creatures" do
    expect(forerunners.power).to eq(7)
    expect(opponent_elves.power).to eq(1)
    expect(opponent_elves.toughness).to eq(1)
    expect(opponent_elves).not_to be_vigilant
    expect(opponent_elves.trample?).to eq(false)
  end
end
