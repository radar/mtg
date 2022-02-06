require 'spec_helper'

RSpec.describe Magic::Player do
  include_context "two player game"

  context "draw" do
    it "draws a card" do
      p1.draw!
      expect(p1.hand.cards.by_name("Forest").count).to eq(1)
    end
  end

  context "cast!" do
    context "with an island" do
      let(:island) { Card("Island") }

      before do
        p1.hand.add(island)
      end

      it "plays the island" do
        island.play!
        expect(p1.hand).not_to include(island)
        expect(island.zone).to be_battlefield
      end
    end
  end
end
