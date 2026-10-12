# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SaviorOfTheSmall do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:savior) { ResolvePermanent("Savior Of The Small", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p1) }
  let!(:big) { Card("Terror Of The Peaks", owner: p1) }
  let!(:bolt) { Card("Lightning Bolt", owner: p1) }

  before { [bears, big, bolt].each { |card| p1.graveyard.add(card) } }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 3/4 Kor Survivor" do
    expect([savior.power, savior.toughness]).to eq([3, 4])
    expect(savior.type?("Survivor")).to be true
  end

  it "returns the only creature card with mana value 3 or less when tapped" do
    savior.tap!
    to_second_main!

    expect(p1.hand.cards).to include(bears)
    expect(p1.hand.cards).not_to include(big)
    expect(p1.hand.cards).not_to include(bolt)
  end

  it "does nothing if untapped" do
    to_second_main!

    expect(p1.graveyard.cards).to include(bears)
  end
end
