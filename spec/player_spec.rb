require 'spec_helper'

RSpec.describe Magic::Player do
  include_context "two player game"

  let(:island) { Card("Island") }

  context "draw" do
    before do
      p1.library.add(island)
    end

    it "draws a card" do
      p1.draw!
      expect(p1.hand).to include(island)
      expect(p1.library.cards).to be_empty
    end
  end

  context "cast!" do
    context "with an island" do
      before do
        p1.hand.add(island)
      end

      it "plays the island" do
        p1.cast!(island)
        expect(p1.hand).not_to include(island)
        expect(island.zone).to be_battlefield
      end
    end
  end
end
