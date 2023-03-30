require 'spec_helper'

RSpec.describe Magic::Cards::RiseAgain do
  include_context "two player game"

  let(:card) { described_class.new(game: game) }
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
      graveyard_event = game.current_turn.events.find { |event| event.is_a?(Magic::Events::PermanentLeavingZone) }
      expect(graveyard_event.permanent.name).to eq(wood_elves.name)
      expect(graveyard_event.from).to be_graveyard
      expect(graveyard_event.to).to be_battlefield
    end
  end
end
