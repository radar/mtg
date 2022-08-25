require 'spec_helper'

RSpec.describe Magic::Cards::LegionsJudgement do
  include_context "two player game"

  let(:card) { described_class.new(game: game) }

  context "with a creature with power over 4" do
    let!(:hill_giant_herdgorger) { ResolvePermanent("Hill Giant Herdgorger", game: game, controller: p2) }

    it "destroys the giant" do
      cast_and_resolve(card: card, player: p1, targeting: hill_giant_herdgorger)
      expect(hill_giant_herdgorger.zone).to be_graveyard
    end
  end

  context "with a creature with power under 4" do
    let(:wood_elves) { ResolvePermanent("Wood Elves", game: game, controller: p2) }

    it "does not have wood elves as targets" do
      expect(card.target_choices).not_to include(wood_elves)
    end
  end

end
