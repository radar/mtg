# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HouseCartographer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:cartographer) { ResolvePermanent("House Cartographer", owner: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 2/2 Human Scout Survivor" do
    expect([cartographer.power, cartographer.toughness]).to eq([2, 2])
    expect(cartographer.type?("Survivor")).to be(true)
  end

  it "puts the first land into hand and the rest on the bottom when tapped" do
    spells = 3.times.map { Card("Grizzly Bears", owner: p1) }
    land = Card("Forest", owner: p1)
    [*spells, land].reverse_each { |card| p1.library.add(card) }
    cartographer.tap!

    expect { to_second_main! }.to change { p1.hand.count }.by(1)

    expect(p1.hand.cards).to include(land)
    expect(p1.library.cards.last(3)).to match_array(spells)
  end

  it "does nothing if the creature is untapped" do
    expect { to_second_main! }.not_to(change { p1.hand.count })
  end
end
