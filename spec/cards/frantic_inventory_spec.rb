require 'spec_helper'

RSpec.describe Magic::Cards::FranticInventory do
  include_context "two player game"

  subject { Card("Frantic Inventory") }

  context "resolution" do
    it "draws a single card" do
      expect(p1).to receive(:draw!)
      cast_and_resolve(card: subject, player: p1)
    end

    context "when another Frantic Inventory is in the player's graveyard" do
      before do
        p1.graveyard << Card("Frantic Inventory")
      end

      it "draws two cards" do
        expect(p1).to receive(:draw!).twice
        cast_and_resolve(card: subject, player: p1)
      end
    end
  end
end
