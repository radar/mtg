require 'spec_helper'

RSpec.describe 'When creatures die, auras attached to them are sent to graveyards' do
  include_context "two player game"

  let(:faiths_fetters) { Card("Faith's Fetters") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  it "wood elves is destroyed" do
    p1.hand.add(faiths_fetters)
    cast_and_resolve(card: faiths_fetters, player: p1, targeting: wood_elves)
    fetters = wood_elves.attachments.first
    wood_elves.destroy!

    aggregate_failures do
      expect(wood_elves).to be_dead
      expect(fetters.zone).to be_nil
      expect(fetters.card.zone).to eq(p1.graveyard)
    end
  end
end
