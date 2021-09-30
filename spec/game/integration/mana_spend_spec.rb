require 'spec_helper'

RSpec.describe Magic::Game, "Mana spend" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }

  context "when at first main phase" do
    before do
      subject.step.force_state!(:draw)
      subject.next_step
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
        p1.cast!(essence_warden, green: 1)
        game.stack.resolve!
        expect(essence_warden.zone).to be_battlefield
        expect(p1.mana_pool[:green]).to eq(0)
      end
    end

    context "with 3 mountains and a foundry inspector on the battlefield, and a sol ring in hand" do
      let(:foundry_inspector) { Card("Foundry Inspector") }
      let(:sol_ring) { Card("Sol Ring") }

      before do
        3.times { game.battlefield.add(Card("Mountain", controller: p1)) }
        p1.hand.add(foundry_inspector)
        p1.hand.add(sol_ring)
      end

      it "casts a foundry inspector and then a sol ring" do
        mountains = game.battlefield.cards.select { |c| c.name == "Mountain" }
        mountains.each { |mountain| p1.tap!(mountain) }

        expect(p1.mana_pool[:red]).to eq(3)
        expect(p1.can_cast?(foundry_inspector)).to eq(true)
        p1.cast!(foundry_inspector, { generic: { red: 3 } })
        game.stack.resolve!
        expect(p1.mana_pool).to be_empty
        p1.cast!(sol_ring)
        game.stack.resolve!
        expect(sol_ring.zone).to be_battlefield
      end
    end
  end
end
