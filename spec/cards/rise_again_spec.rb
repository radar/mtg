require 'spec_helper'

RSpec.describe Magic::Cards::RiseAgain do
  include_context "two player game"

  let(:card) { described_class.new(game: game) }

  context "brings back creature from player's graveyard" do
    before do
      p1.graveyard << Card("Wood Elves")
    end

    it "moves Wood Elves back to battlefield" do
      cast_and_resolve(card: card, player: p1, targeting: p1.graveyard.cards.first)
      expect(p1.permanents.by_name("Wood Elves").count).to eq(1)
    end
  end
end
