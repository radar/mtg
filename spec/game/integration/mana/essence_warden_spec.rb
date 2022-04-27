require 'spec_helper'

RSpec.describe Magic::Game, "Mana spend -- Essence Warden" do
  include_context "two player game"

  context "when at first main phase" do
    context "when mana cost is not payable" do
      let(:essence_warden) { Card("Essence Warden", game: game) }
      before do
        p1.hand.add(essence_warden)
      end

      it "cannot cast the essence warden" do
        expect(p1.can_cast?(essence_warden)).to eq(false)
      end
    end

    context "with a forest on the battlefield, and essence warden in hand" do
      let(:essence_warden) { Card("Essence Warden", game: game) }
      let(:forest) { Card("Forest", game: game) }

      before do
        p1.hand.add(forest)
        p1.hand.add(essence_warden)
      end

      it "casts a forest, then an essence warden" do
        expect(p1.can_cast?(forest)).to eq(true)
        cast_action = p1.prepare_to_cast(forest)
        cast_action.perform!
        p1.tap!(forest)
        expect(p1.mana_pool[:green]).to eq(1)
        expect(p1.can_cast?(essence_warden)).to eq(true)
        cast = p1.prepare_to_cast(essence_warden)
        cast.pay(green: 1)
        cast.perform!
        game.stack.resolve!
        expect(p1.mana_pool[:green]).to eq(0)
        expect(essence_warden.zone).to be_battlefield

      end
    end
  end
end
