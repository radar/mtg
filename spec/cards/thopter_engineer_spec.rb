# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThopterEngineer do
  include_context "two player game"

  let!(:engineer) { ResolvePermanent("Thopter Engineer", owner: p1) }

  def thopters = p1.creatures.select { |c| c.name == "Thopter" && c.token? }

  it "creates a 1/1 colorless flying artifact Thopter" do
    expect(thopters.count).to eq(1)
    expect([thopters.first.power, thopters.first.toughness]).to eq([1, 1])
    expect(thopters.first).to be_flying
    expect(thopters.first.type?("Artifact")).to be true
  end

  it "gives artifact creatures you control haste" do
    game.tick!
    expect(thopters.first).to have_keyword(:haste)
  end

  it "does not give haste to a nonartifact creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    game.tick!

    expect(bears).not_to have_keyword(:haste)
  end

  it "does not give an opponent's artifact creatures haste" do
    other = ResolvePermanent("Circuit Mender", owner: p2, summoning_sick: true)
    game.tick!

    expect(other).not_to have_keyword(:haste)
  end
end
