require 'spec_helper'

RSpec.describe Magic::Cards::LegionsJudgement do
  include_context "two player game"

  let(:card) { described_class.new(game: game, controller: p1) }

  context "with a creature with power over 4" do
    let(:hill_giant_herdgorger) { Card("Hill Giant Herdgorger", game: game, controller: p2) }

    before do
      game.battlefield.add(hill_giant_herdgorger)
    end

    it "destroys the giant" do
      card.cast!
      game.stack.resolve!
      expect(hill_giant_herdgorger.zone).to be_graveyard
    end
  end

  context "with a creature with power under 4" do
    let(:wood_elves) { Card("Wood Elves", game: game, controller: p2) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "does not destroy the wood elves" do
      card.cast!
      game.stack.resolve!
      expect(wood_elves.zone).to be_battlefield
    end
  end

end
