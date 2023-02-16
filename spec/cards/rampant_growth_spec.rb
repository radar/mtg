require 'spec_helper'

RSpec.describe Magic::Cards::RampantGrowth do
  include_context "two player game"

  let(:card) { described_class.new(game: game) }

  def p1_library
    8.times.map { Card("Forest") }
  end

  it "search for land effect" do
    cast_and_resolve(card: card, player: p1)
    forest = game.battlefield.cards.by_name("Forest").first
    expect(forest).to be_tapped
  end
end
