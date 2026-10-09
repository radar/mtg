# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LakeTownToymaker do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:toymaker) { ResolvePermanent("Lake Town Toymaker", owner: p1) }
  let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }

  it "is a 3/4" do
    expect(toymaker.power).to eq(3)
    expect(toymaker.toughness).to eq(4)
  end

  it "does nothing at beginning of combat if you drew fewer than two cards" do
    current_turn.beginning_of_combat!
    expect(game.choices).to be_empty
    expect(bear.power).to eq(5)
  end

  it "pumps another creature at beginning of combat after drawing two cards" do
    p1.draw!
    current_turn.beginning_of_combat!
    game.tick!
    expect(bear.power).to eq(8)
    expect(bear.keywords).to include(Magic::Cards::Keywords::FIRST_STRIKE)
    expect(toymaker.power).to eq(3)
  end
end
