# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheNecrobloom do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:necrobloom) { ResolvePermanent("The Necrobloom", owner: p1) }

  def tokens(name) = p1.creatures.select { _1.token? && _1.name == name }

  describe "landfall" do
    it "creates a 0/1 Plant token" do
      ResolvePermanent("Forest", owner: p1)
      game.settle!

      plant = tokens("Plant").first
      expect(plant).not_to be_nil
      expect([plant.power, plant.toughness]).to eq([0, 1])
    end

    it "creates a 2/2 Zombie instead with seven differently named lands" do
      %w[Forest Island Mountain Swamp Plains].each { ResolvePermanent(_1, owner: p1) }
      ResolvePermanent("Dakmor Salvage", owner: p1)
      ResolvePermanent("Shifting Woodland", owner: p1)
      game.settle!
      plants_before = tokens("Plant").count

      ResolvePermanent("Arena Of Glory", owner: p1)
      game.settle!

      expect(tokens("Plant").count).to eq(plants_before)
      zombie = tokens("Zombie").first
      expect([zombie.power, zombie.toughness]).to eq([2, 2])
    end

    it "ignores an opponent's land" do
      ResolvePermanent("Forest", owner: p2)
      game.settle!

      expect(tokens("Plant")).to be_empty
    end
  end

  describe "dredge 2 for lands in your graveyard" do
    let!(:forest) { Card("Forest", owner: p1) }

    before { p1.graveyard.add(forest) }

    it "mills two and returns the land to hand" do
      library_size = p1.library.count
      p1.dredge!(forest)

      expect(p1.hand.cards).to include(forest)
      expect(p1.library.count).to eq(library_size - 2)
    end

    it "does not apply to nonland cards" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.graveyard.add(bears)

      expect { p1.dredge!(bears) }.to raise_error(Magic::Error)
    end

    describe "when you would draw" do
      def draw_a_card
        game.add_effect(Magic::Effects::DrawCards.new(source: p1, player: p1))
      end

      it "offers the land and a normal draw" do
        draw_a_card

        expect(game.choices.last.modes.keys).to eq([forest, :draw])
      end

      it "dredges the land instead of drawing" do
        top = p1.library.first
        library_size = p1.library.count
        draw_a_card
        game.resolve_choice!(mode: forest)

        expect(p1.hand.cards).to include(forest)
        expect(p1.hand.cards).not_to include(top)
        expect(p1.graveyard.cards).to include(top)
        expect(p1.library.count).to eq(library_size - 2)
      end

      it "draws normally when you decline" do
        top = p1.library.first
        draw_a_card
        game.resolve_choice!(mode: :draw)

        expect(p1.hand.cards).to include(top)
        expect(p1.graveyard.cards).to include(forest)
      end

      it "offers the dredge again for each further card drawn" do
        game.add_effect(Magic::Effects::DrawCards.new(source: p1, player: p1, number_to_draw: 2))
        game.resolve_choice!(mode: forest)

        expect(game.choices.last).to be_a(described_class::DredgeChoice)
      end

      it "does not offer a dredge when the library is too small" do
        p1.library.cards.drop(1).each { p1.library.remove(_1) }
        draw_a_card

        expect(game.choices).to be_empty
      end

      it "does not offer a dredge when no land is in the graveyard" do
        p1.graveyard.remove(forest)
        draw_a_card

        expect(game.choices).to be_empty
      end

      it "does not apply to an opponent's draw" do
        game.add_effect(Magic::Effects::DrawCards.new(source: p2, player: p2))

        expect(game.choices).to be_empty
      end
    end
  end
end
