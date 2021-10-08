require 'spec_helper'

RSpec.describe Magic::Game, "Mana spend -- Essence Warden" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }

  context "when at first main phase" do
    before do
      subject.go_to_beginning_of_combat!
    end

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
        p1.cast!(forest)
        p1.tap!(forest)
        expect(p1.mana_pool[:green]).to eq(1)
        expect(p1.can_cast?(essence_warden)).to eq(true)
        cast = p1.prepare_to_cast!(essence_warden)
        cast.pay(green: 1)
        cast.perform!
        game.stack.resolve!
        expect(p1.mana_pool[:green]).to eq(0)
        expect(essence_warden.zone).to be_battlefield

      end
    end
  end
end
