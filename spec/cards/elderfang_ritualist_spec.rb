require 'spec_helper'

RSpec.describe Magic::Cards::ElderfangRitualist do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  subject { described_class.new(controller: p1, game: game) }

  context "dies" do
    context "when p1 has wood elves in the graveyard" do
      let(:wood_elves) { Card("Wood Elves") }

      before do
        p1.graveyard.add(wood_elves)
      end

      let(:event) do
        Magic::Events::LeavingZone.new(
          subject,
          from: game.battlefield,
          to: p1.graveyard
        )
      end

      it "brings back wood elves" do
        subject.receive_notification(event)
        game.stack.resolve!
        expect(game.stack.pending_effects?).to eq(false)
        expect(wood_elves.zone).to eq(p1.hand)
      end
    end
  end
end
