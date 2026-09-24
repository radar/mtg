require "spec_helper"

RSpec.describe Magic::Cards::PesteredWellguard do
  include_context "two player game"

  let!(:wellguard) { ResolvePermanent("Pestered Wellguard", owner: p1) }

  it "is a 3/2" do
    expect([wellguard.power, wellguard.toughness]).to eq([3, 2])
  end

  it "creates a 1/1 blue and black Faerie token with flying whenever it becomes tapped" do
    wellguard.tap!
    game.settle!
    faerie = game.battlefield.creatures.by_name("Faerie").first

    expect([faerie.power, faerie.toughness]).to eq([1, 1])
    expect(faerie.colors).to contain_exactly(:blue, :black)
    expect(faerie).to be_flying
  end

  it "triggers each time it becomes tapped" do
    2.times do
      wellguard.untap!
      wellguard.tap!
      game.settle!
    end

    expect(game.battlefield.creatures.by_name("Faerie").count).to eq(2)
  end
end
