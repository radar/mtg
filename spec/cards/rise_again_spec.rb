require 'spec_helper'

RSpec.describe Magic::Cards::RiseAgain do
  include_context "two player game"

  let(:card) { Card("Rise Again") }
  let(:wood_elves) { Card("Wood Elves") }

  context "brings back creature from player's graveyard" do
    before do
      p1.graveyard.add(wood_elves)
    end

    it "moves Wood Elves back to battlefield" do
      expect(wood_elves.zone).to be_graveyard
      cast_and_resolve(card: card, player: p1, targeting: p1.graveyard.cards.first)
      expect(p1.permanents.by_name("Wood Elves").count).to eq(1)
      expect(wood_elves.zone).to be_battlefield
      zone_change_event = game.current_turn.events.find { |event| event.is_a?(Magic::Events::CardEnteredZone) && event.card == wood_elves}
      expect(zone_change_event.from).to be_graveyard
      expect(zone_change_event.to).to be_battlefield
    end
  end
end
