require 'spec_helper'

RSpec.describe Magic::Cards::RampantGrowth do
  include_context "two player game"

  let(:card) { described_class.new(game: game, controller: p1) }

  it "search for land effect" do
    card.cast!
    game.stack.resolve!
    forest = game.battlefield.cards.by_name("Forest").first
    expect(forest).to be_tapped
  end
end
