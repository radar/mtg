# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScuzzbackScrounger do
  include_context "two player game"

  let!(:scrounger) { ResolvePermanent("Scuzzback Scrounger", owner: p1) }

  def treasures = p1.permanents.select { |permanent| permanent.name == "Treasure" }

  it "is a 3/2 goblin warrior" do
    expect(scrounger.card.types).to include("Goblin", "Warrior")
    expect(scrounger.power).to eq(3)
    expect(scrounger.toughness).to eq(2)
  end

  it "may blight 1 at the beginning of its controller's first main phase; if it does, creates a Treasure token" do
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!

    game.resolve_choice! # accept the "may"
    game.resolve_choice!(target: scrounger)

    expect(scrounger.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    expect(treasures.count).to eq(1)
  end

  it "does nothing when declined" do
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!

    game.skip_choice!

    expect(scrounger.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)
    expect(treasures.count).to eq(0)
  end

  it "does not trigger on an opponent's first main phase" do
    go_to_main_phase_for!(p2)

    expect(game.choices).to be_empty
  end
end
