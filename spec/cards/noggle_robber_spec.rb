# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NoggleRobber do
  include_context "two player game"

  let!(:robber) { ResolvePermanent("Noggle Robber", owner: p1) }

  def treasures = p1.permanents.select { |permanent| permanent.name == "Treasure" }

  it "is a 3/3 noggle rogue" do
    expect(robber.card.types).to include("Noggle", "Rogue")
    expect(robber.power).to eq(3)
    expect(robber.toughness).to eq(3)
  end

  it "creates a Treasure token when it enters" do
    expect(treasures.count).to eq(1)
  end

  it "creates a Treasure token when it dies" do
    robber.destroy!
    game.settle!

    expect(treasures.count).to eq(2)
  end
end
