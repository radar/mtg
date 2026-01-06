require 'spec_helper'

RSpec.describe Magic::Cards::SazhsChocobo do
  include_context "two player game"

  let!(:permanent) { ResolvePermanent("Sazh's Chocobo") }

  before do
    p1.hand.add(Card("Forest"))
  end

  describe "landfall ability" do
    it "triggers when you play a land" do
      p1.play_land(land: p1.hand.cards.by_name("Forest").first)

      expect(permanent.counters.count).to eq(1)
      expect(permanent.counters.of_type(Magic::Counters["+1/+1"]).count).to eq(1)
    end
  end
end
