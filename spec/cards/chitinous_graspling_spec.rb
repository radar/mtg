# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChitinousGraspling do
  include_context "two player game"

  let!(:graspling) { ResolvePermanent("Chitinous Graspling", owner: p1) }

  it "is a 3/4 shapeshifter" do
    expect(graspling.card.types).to include("Creature")
    expect(graspling.power).to eq(3)
    expect(graspling.toughness).to eq(4)
  end

  it "has changeling, so it's every creature type" do
    expect(graspling.card.changeling?).to be(true)
    expect(graspling.card.type?("Faerie")).to be(true)
  end

  it "has reach" do
    expect(graspling.reach?).to be(true)
  end
end
