# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Player do
  include_context "two player game"

  context "draw" do
    def p1_library
      [
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Mountain"),
      ]
    end

    it "draws a card" do
      # Initial game draw
      expect(p1.hand.cards.by_name("Forest").count).to eq(7)
      p1.draw!
      expect(p1.hand.cards.by_name("Mountain").count).to eq(1)
    end
  end

  context "reveal" do
    let(:forest) { p1.hand.cards.first }

    it "reveals cards in hand and fires CardsRevealed event" do
      expect(forest).not_to be_revealed
      p1.reveal(forest)

      expect(forest).to be_revealed
      expect(p1.revealed_cards).to include(forest)
      expect(p1.hand.revealed).to include(forest)

      revealed_event = game.current_turn.events.find { |e| e.is_a?(Magic::Events::CardsRevealed) }
      expect(revealed_event).not_to be_nil
      expect(revealed_event.cards).to eq([forest])
      expect(revealed_event.player).to eq(p1)
    end
  end
end
