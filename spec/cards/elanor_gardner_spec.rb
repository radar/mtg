# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElanorGardner do
  include_context "two player game"

  let!(:elanor) { ResolvePermanent("Elanor Gardner", owner: p1) }
  let!(:forest) { Card("Forest", owner: p1) }

  before { p1.library.add(forest) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def end_step!
    current_turn.end!
    game.settle!
  end

  it "is a 2/4" do
    expect([elanor.power, elanor.toughness]).to eq([2, 4])
  end

  it "creates a Food token when it enters" do
    expect(foods.count).to eq(1)
  end

  it "searches for a basic land tapped at end step after sacrificing a Food" do
    foods.first.sacrifice!
    game.settle!
    end_step!
    game.resolve_choice!(targets: [forest])

    expect(p1.lands.map(&:name)).to eq(["Forest"])
    expect(p1.lands.first).to be_tapped
  end

  it "may decline the search" do
    foods.first.sacrifice!
    game.settle!
    end_step!
    game.skip_choice!

    expect(p1.lands).to be_empty
    expect(game.choices).to be_empty
  end

  it "does nothing at end step if no Food was sacrificed" do
    end_step!

    expect(game.choices).to be_empty
    expect(p1.lands).to be_empty
  end

  it "does not trigger for a non-Food sacrifice" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.sacrifice!
    game.settle!
    end_step!

    expect(game.choices).to be_empty
  end

  it "does not trigger when only the opponent sacrificed a Food" do
    opp_food = Magic::Tokens::Food.new(game: game, owner: p2).resolve!
    opp_food.sacrifice!
    game.settle!
    end_step!

    expect(game.choices).to be_empty
  end
end
