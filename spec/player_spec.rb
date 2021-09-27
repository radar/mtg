require 'spec_helper'

RSpec.describe Magic::Player do
  context "draw" do
    let(:island) { Magic::Cards::Island.new }
    let(:library) { Magic::Library.new([island]) }
    subject(:player) { described_class.new(library: library) }

    it "draws a card" do
      player.draw!
      expect(player.hand).to include(island)
      expect(library.cards).to be_empty
    end
  end

  context "play" do
    let(:island) { Magic::Cards::Island.new }
    subject(:player) { described_class.new(library: Magic::Library.new([island])) }

    it "plays the island" do
      player.draw!
      player.play!(island)
      expect(player.hand).not_to include(island)
      expect(island.zone).to be_battlefield
    end
  end

  context "can_cast?" do
    let(:card) { Magic::Card.new(name: "Loxodon Wayfarer", cost: { any: 2, white: 1 }, controller: player) }
    subject(:player) { described_class.new }

    context "when the player has enough mana" do
      it "is castable" do
        player.add_mana(white: 1, red: 2)
        expect(player.can_cast?(card)).to eq(true)
      end
    end

    context "when the player does not have enough mana" do
      let(:player) { described_class.new(mana_pool: { red: 1, white: 1 })}

      it "is castable" do
        expect(player.can_cast?(card)).to eq(false)
      end
    end
  end
end
