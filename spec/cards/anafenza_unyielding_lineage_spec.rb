# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AnafenzaUnyieldingLineage do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Anafenza, Unyielding Lineage", owner: p1) }

  def counters = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "has flash and first strike" do
    expect(permanent.keywords).to include(Magic::Cards::Keywords::FLASH, Magic::Cards::Keywords::FIRST_STRIKE)
  end

  it "endures 2 when another nontoken creature you control dies" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    game.resolve_choice!
    expect(counters).to eq(2)
  end

  it "or creates a 2/2 white Spirit token" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    game.skip_choice!
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([2, 2])
  end

  it "ignores a token dying" do
    Magic::Choice::Endure::SpiritToken.new(game:, owner: p1).resolve!.destroy!
    game.settle!
    expect(game.choices).to be_empty
  end

  it "ignores an opponent's creature dying" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    expect(game.choices).to be_empty
  end
end
