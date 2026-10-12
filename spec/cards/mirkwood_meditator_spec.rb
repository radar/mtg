# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MirkwoodMeditator do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:meditator) { ResolvePermanent("Mirkwood Meditator", owner: p1) }

  it "is a 2/4" do
    expect(meditator.power).to eq(2)
    expect(meditator.toughness).to eq(4)
  end

  it "may become 4/2 until end of turn when a land enters under your control" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    game.resolve_choice!
    game.tick!
    expect(meditator.power).to eq(4)
    expect(meditator.toughness).to eq(2)
  end

  it "stays 2/4 if you decline" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    game.skip_choice!
    expect(meditator.power).to eq(2)
    expect(meditator.toughness).to eq(4)
  end

  it "does not trigger for an opponent's land" do
    ResolvePermanent("Forest", owner: p2)
    game.settle!
    expect(game.choices).to be_empty
  end
end
