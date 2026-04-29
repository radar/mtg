# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::TrackDown do
  include_context "two player game"

  let(:track_down) { Card("Track Down") }

  def p1_library
    [
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      # End initial card draw
      Card("Grizzly Bears"),
      Card("Sol Ring"),
      Card("Forest"),
    ]
  end

  def cast_track_down
    p1.add_mana(green: 2)
    p1.cast(card: track_down) do
      _1.pay_mana(generic: { green: 1 }, green: 1)
    end
    game.stack.resolve!
  end

  it "presents a scry 3 choice" do
    cast_track_down

    choice = game.choices.last
    expect(choice).to be_a(Magic::Cards::TrackDown::ScryChoice)
    expect(choice.amount).to eq(3)
  end

  context "when the top card after scry is a creature" do
    it "draws a card after revealing the creature" do
      cast_track_down

      top_three = p1.library.first(3)
      game.resolve_choice!(top: top_three)

      # Grizzly Bears is next on top after the scry - it was already drawn into hand
      expect(p1.hand.map(&:name)).to include("Grizzly Bears")
    end

    it "fires a CardsRevealed event" do
      cast_track_down

      top_three = p1.library.first(3)
      game.resolve_choice!(top: top_three)

      revealed_event = game.current_turn.events.find { |e| e.is_a?(Magic::Events::CardsRevealed) }
      expect(revealed_event).not_to be_nil
    end
  end

  context "when the top card after scry is a land" do
    def p1_library
      [
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        # End initial card draw
        Card("Forest"),
        Card("Sol Ring"),
        Card("Mountain"),
      ]
    end

    it "draws a card after revealing the land" do
      cast_track_down

      top_three = p1.library.first(3)
      hand_size_before = p1.hand.count
      game.resolve_choice!(top: top_three)

      # Top card was a Forest (land), so draws it
      expect(p1.hand.count).to eq(hand_size_before + 1)
    end
  end

  context "when the top card after scry is neither a creature nor a land" do
    def p1_library
      [
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        Card("Forest"),
        # End initial card draw
        Card("Sol Ring"),
        Card("Forest"),
        Card("Mountain"),
      ]
    end

    it "does not draw a card" do
      cast_track_down

      top_three = p1.library.first(3)
      hand_size_before = p1.hand.count
      game.resolve_choice!(top: top_three)

      # Top card was Sol Ring (artifact), so no draw
      expect(p1.hand.count).to eq(hand_size_before)
    end
  end
end
