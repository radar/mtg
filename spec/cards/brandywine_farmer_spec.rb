# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BrandywineFarmer do
  include_context "two player game"

  def foods = p1.permanents.select { _1.type?("Food") }

  it "is a 1/1 Halfling Peasant" do
    card = Card("Brandywine Farmer")
    expect(card.base_power).to eq(1)
    expect(card.base_toughness).to eq(1)
    expect(card.type?("Halfling")).to be(true)
    expect(card.type?("Peasant")).to be(true)
  end

  it "creates a Food token when it enters" do
    ResolvePermanent("Brandywine Farmer", owner: p1)
    game.settle!

    expect(foods.count).to eq(1)
  end

  it "creates a Food token when it leaves the battlefield" do
    farmer = ResolvePermanent("Brandywine Farmer", owner: p1)
    game.settle!
    expect(foods.count).to eq(1)

    farmer.destroy!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Brandywine Farmer")
    expect(foods.count).to eq(2)
  end

  it "does not create a Food for the opponent" do
    ResolvePermanent("Brandywine Farmer", owner: p1)
    game.settle!

    expect(p2.permanents.select { _1.type?("Food") }).to be_empty
  end
end
