# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EastfarthingFarmer do
  include_context "two player game"

  def foods = p1.permanents.select { _1.type?("Food") }

  def food = Magic::Tokens::Food.new(game: game, owner: p1).resolve!

  it "is a 2/3 Halfling Peasant" do
    card = Card("Eastfarthing Farmer")
    expect([card.base_power, card.base_toughness]).to eq([2, 3])
    expect(card.type?("Halfling")).to be(true)
    expect(card.type?("Peasant")).to be(true)
  end

  it "creates a Food token for its controller when it enters" do
    ResolvePermanent("Eastfarthing Farmer", owner: p1)
    game.settle!

    expect(foods.count).to eq(1)
    expect(p2.permanents.select { _1.type?("Food") }).to be_empty
  end

  context "with another creature to target" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "gives the target +1/+1 for each Food you control, counting the new Food" do
      food
      farmer = ResolvePermanent("Eastfarthing Farmer", owner: p1)
      game.settle!
      game.resolve_choice!(target: bears)
      game.settle!

      expect(foods.count).to eq(2)
      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect([farmer.power, farmer.toughness]).to eq([2, 3])
    end

    it "can target the Farmer itself" do
      ResolvePermanent("Eastfarthing Farmer", owner: p1).tap { game.settle! }
      expect(game.choices.last.choices).to include(bears)
      game.resolve_choice!(target: game.choices.last.choices.find { _1.name == "Eastfarthing Farmer" })
      game.settle!

      expect(p1.creatures.find { _1.name == "Eastfarthing Farmer" }.power).to eq(3)
    end

    it "only offers creatures you control" do
      ResolvePermanent("Eastfarthing Farmer", owner: p1)
      game.settle!

      expect(game.choices.last.choices).not_to include(theirs)
    end

    it "wears off at end of turn" do
      ResolvePermanent("Eastfarthing Farmer", owner: p1)
      game.settle!
      game.resolve_choice!(target: bears)
      game.settle!
      expect(bears.power).to eq(3)

      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(bears.power).to eq(2)
    end

    it "gives nothing when the choice is declined" do
      ResolvePermanent("Eastfarthing Farmer", owner: p1)
      game.settle!
      game.skip_choice!
      game.settle!

      expect(bears.power).to eq(2)
    end
  end
end
