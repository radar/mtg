require 'spec_helper'

RSpec.describe Magic::Player do
  let(:game) { Magic::Game.new }
  context "draw" do
    let(:island) { Card("Island") }
    subject(:player) { game.add_player(library: [island]) }

    it "draws a card" do
      player.draw!
      expect(player.hand).to include(island)
      expect(player.library.cards).to be_empty
    end
  end

  context "cast!" do
    context "with an island" do
      let(:island) { Card("Island") }
      subject(:player) { game.add_player(library: [island]) }

      it "plays the island" do
        player.draw!
        player.cast!(island)
        expect(player.hand).not_to include(island)
        expect(island.zone).to be_battlefield
      end
    end
  end
end
