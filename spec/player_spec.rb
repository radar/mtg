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

  describe "#behind_an_opponent_in?" do
    it "is true only when an opponent has strictly more of the stat" do
      expect(p1.behind_an_opponent_in?(:lands)).to be false

      ResolvePermanent("Forest", owner: p2)
      expect(p1.behind_an_opponent_in?(:lands)).to be true

      ResolvePermanent("Forest", owner: p1)
      expect(p1.behind_an_opponent_in?(:lands)).to be false
    end

    it "compares life" do
      p1.lose_life(5)

      expect(p1.behind_an_opponent_in?(:life)).to be true
      expect(p2.behind_an_opponent_in?(:life)).to be false
    end

    it "raises for a stat it doesn't know" do
      expect { p1.behind_an_opponent_in?(:mana) }.to raise_error(ArgumentError, /Unknown stat :mana/)
    end
  end

  describe "#mill" do
    it "mills as many cards as the library holds, without failing, when it has fewer than asked" do
      p1.library.cards.clear
      p1.library.add(Card("Forest", owner: p1))

      expect(p1.mill(3).count).to eq(1)
      expect(p1.graveyard.count).to eq(1)
      expect(p1.library.count).to eq(0)
    end
  end
end
