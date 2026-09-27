# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MerrowSkyswimmer do
  include_context "two player game"

  it "is a 2/2 merfolk soldier with flying, vigilance and convoke" do
    skyswimmer = ResolvePermanent("Merrow Skyswimmer", owner: p1)

    expect(skyswimmer.card.types).to include("Merfolk", "Soldier")
    expect(skyswimmer.power).to eq(2)
    expect(skyswimmer.toughness).to eq(2)
    expect(skyswimmer.flying?).to be(true)
    expect(skyswimmer).to have_keyword(:vigilance)
    expect(skyswimmer.card.convoke?).to be(true)
  end

  it "creates a 1/1 white and blue Merfolk token when it enters" do
    ResolvePermanent("Merrow Skyswimmer", owner: p1)

    tokens = p1.permanents.select { |permanent| permanent.name == "Merfolk" }
    expect(tokens.count).to eq(1)
    expect(tokens.first.power).to eq(1)
    expect(tokens.first.toughness).to eq(1)
  end
end
