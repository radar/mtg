# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BladeSplicer do
  include_context "two player game"

  let!(:splicer) { ResolvePermanent("Blade Splicer", owner: p1) }

  def golems = p1.creatures.select { |c| c.name == "Golem" && c.token? }

  it "is a 1/1" do
    expect([splicer.power, splicer.toughness]).to eq([1, 1])
  end

  it "creates a 3/3 colorless Golem artifact creature token" do
    expect(golems.count).to eq(1)
    expect([golems.first.power, golems.first.toughness]).to eq([3, 3])
    expect(golems.first.type?("Artifact")).to be true
    expect(golems.first.colors).to be_empty
  end

  it "gives Golems you control first strike" do
    game.tick!
    expect(golems.first).to have_keyword(:first_strike)
  end

  it "does not give other creatures first strike" do
    expect(splicer).not_to have_keyword(:first_strike)
  end
end
