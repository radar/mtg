# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AcrobaticCheerleader do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:cheerleader) { ResolvePermanent("Acrobatic Cheerleader", owner: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 2/2 without flying" do
    expect(cheerleader.power).to eq(2)
    expect(cheerleader).not_to be_flying
  end

  it "gets a flying counter at second main if tapped" do
    cheerleader.tap!
    to_second_main!
    game.tick!
    expect(cheerleader).to be_flying
  end

  it "does nothing if untapped" do
    to_second_main!
    game.tick!
    expect(cheerleader).not_to be_flying
  end

  it "triggers only once" do
    cheerleader.tap!
    to_second_main!
    expect(cheerleader.triggered_ever?(described_class::SurvivalTrigger)).to be(true)
    expect(cheerleader.counters.size).to eq(1)
  end
end
