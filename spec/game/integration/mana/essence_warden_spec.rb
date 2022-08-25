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
        action = Magic::Actions::Cast.new(player: p1, card: essence_warden)
        expect(action.can_perform?).to eq(false)

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
        action = Magic::Actions::Cast.new(player: p1, card: forest)
        expect(action.can_perform?).to eq(true)
        game.take_action(action)
        game.tick!

        forest = p1.permanents.by_name("Forest").first
        action = Magic::Actions::ActivateAbility.new(player: p1, permanent: forest, ability: forest.activated_abilities.first)
        game.take_action(action)
        expect(p1.mana_pool[:green]).to eq(1)
        action = Magic::Actions::Cast.new(player: p1, card: essence_warden)
        expect(action.can_perform?).to eq(true)
        action.pay_mana(green: 1)
        game.take_action(action)
        game.tick!
        expect(p1.mana_pool[:green]).to eq(0)
        expect(essence_warden.zone).to be_battlefield

      end
    end
  end
end
