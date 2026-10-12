# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DefiantSurvivor do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:survivor) { ResolvePermanent("Defiant Survivor", owner: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 3/2 Human Survivor" do
    expect([survivor.power, survivor.toughness]).to eq([3, 2])
    expect(survivor.type?("Survivor")).to be(true)
  end

  it "manifests dread at the second main phase if tapped" do
    survivor.tap!
    to_second_main!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  it "does nothing if untapped" do
    to_second_main!

    expect(game.choices).to be_empty
    expect(p1.permanents.count(&:face_down?)).to eq(0)
  end
end
