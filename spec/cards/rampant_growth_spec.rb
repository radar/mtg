require 'spec_helper'

RSpec.describe Magic::Cards::RampantGrowth do
  include_context "two player game"

  before do
    p1.library.add(Card("Forest", game: game))
  end

  let(:card) { described_class.new(game: game, controller: p1) }

  it "search for land effect" do
    card.cast!
    game.stack.resolve!
    forest = game.battlefield.cards.find { |card| card.name == "Forest" }
    expect(forest.zone).to be_battlefield
    expect(forest).to be_tapped
  end
end
