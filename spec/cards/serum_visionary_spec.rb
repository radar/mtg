# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SerumVisionary do
  include_context "two player game"

  before { go_to_main_phase! }

  it "is a 2/2 Vedalken Wizard" do
    visionary = ResolvePermanent("Serum Visionary", owner: p1)
    game.skip_choice! if game.choices.any?

    expect(visionary.power).to eq(2)
    expect(visionary.toughness).to eq(2)
    expect(visionary.types).to include("Vedalken", "Wizard")
  end

  it "draws a card, then scries 2 when it enters" do
    hand_size = p1.hand.count
    ResolvePermanent("Serum Visionary", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
    scry = game.choices.last
    expect(scry).to be_a(Magic::Choice::Scry)
    expect(scry.amount).to eq(2)
    game.skip_choice!
  end
end
