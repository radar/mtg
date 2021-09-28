require 'spec_helper'

RSpec.describe Magic::Player do
  let(:game) { Magic::Game.new }
  context "draw" do
    let(:island) { Magic::Cards::Island.new(game: game) }
    subject(:player) { described_class.new(game: game, library: [island]) }

    it "draws a card" do
      player.draw!
      expect(player.hand).to include(island)
      expect(player.library.cards).to be_empty
    end
  end

  context "cast!" do
    context "with an island" do
      let(:island) { Magic::Cards::Island.new }
      subject(:player) { described_class.new(library: [island]) }

      it "plays the island" do
        player.draw!
        player.cast!(island)
        expect(player.hand).not_to include(island)
        expect(island.zone).to be_battlefield
      end
    end
  end

  context "float_mana" do
    subject(:player) { described_class.new }
    it "cannot float mana it does not have" do
      player.add_mana(white: 1)
      expect { player.float_mana(white: 2) }.to raise_error(Magic::Player::UnfloatableMana)
    end
  end

  context "can_cast?" do
    let(:card) { Magic::Cards::LoxodonWayfarer.new(controller: player) }
    subject(:player) { described_class.new }

    context "when the player has enough mana" do
      it "is castable" do
        player.add_mana(white: 1, red: 2)
        player.float_mana(white: 1, red: 2)
        expect(player.can_cast?(card)).to eq(true)
      end
    end

    context "when the player does not have enough mana" do
      let(:player) { described_class.new(mana_pool: { red: 1, white: 1 })}

      it "is castable" do
        player.float_mana(white: 1, red: 1)
        expect(player.can_cast?(card)).to eq(false)
      end
    end
  end
end
