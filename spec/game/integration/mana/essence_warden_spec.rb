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
        action = p1.prepare_cast(card: essence_warden)
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
        p1.play_land(land: forest)
        game.tick!

        forest = p1.permanents.by_name("Forest").first
        p1.activate_ability(ability: forest.activated_abilities.first)
        expect(p1.mana_pool[:green]).to eq(1)

        action = p1.prepare_cast(card: essence_warden)
        expect(action.can_perform?).to eq(true)
        action.pay_mana(green: 1)
        game.take_action(action)
        game.stack.resolve!
        expect(p1.mana_pool[:green]).to eq(0)
        expect(p1.permanents.by_name(essence_warden.name).count).to eq(1)

      end
    end
  end
end
