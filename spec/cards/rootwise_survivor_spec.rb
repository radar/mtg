# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RootwiseSurvivor do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:survivor) { ResolvePermanent("Rootwise Survivor", owner: p1) }
  let!(:forest) { ResolvePermanent("Forest", owner: p1) }
  let!(:forest2) { ResolvePermanent("Forest", owner: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 3/4 Human Survivor with haste" do
    expect([survivor.power, survivor.toughness]).to eq([3, 4])
    expect(survivor).to be_haste
  end

  it "turns a land into a 3/3 hasty Elemental creature at second main if tapped" do
    survivor.tap!
    to_second_main!
    game.resolve_choice!(target: forest)
    game.settle!
    game.tick!

    expect(forest.creature?).to be(true)
    expect(forest.type?("Elemental")).to be(true)
    expect([forest.power, forest.toughness]).to eq([3, 3])
    expect(forest).to be_haste
    expect(forest2.creature?).to be(false)
  end

  it "does nothing if the creature is untapped" do
    to_second_main!

    expect(game.choices).to be_empty
    expect(forest.creature?).to be(false)
  end

  it "may choose no land" do
    survivor.tap!
    to_second_main!
    game.skip_choice!
    game.settle!

    expect(forest.creature?).to be(false)
  end
end
