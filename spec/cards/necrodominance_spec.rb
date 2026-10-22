# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Necrodominance do
  include_context "two player game"

  it "is a legendary enchantment" do
    permanent = ResolvePermanent("Necrodominance", owner: p1)

    expect(permanent).to be_enchantment
    expect(permanent.card.type?("Legendary")).to be(true)
  end

  describe "skip your draw step" do
    it "does not draw in your draw step" do
      ResolvePermanent("Necrodominance", owner: p1)
      hand_size = p1.hand.count
      go_to_main_phase!

      expect(p1.hand.count).to eq(hand_size)
    end

    it "draws normally without it" do
      hand_size = p1.hand.count
      go_to_main_phase!

      expect(p1.hand.count).to eq(hand_size + 1)
    end
  end

  describe "end step" do
    let!(:necrodominance) { ResolvePermanent("Necrodominance", owner: p1) }

    before { go_to_main_phase! }

    it "lets you pay any amount of life to draw that many cards" do
      hand_size = p1.hand.count
      current_turn.end!
      expect(game.choices.last).to be_a(described_class::PayLifeChoice)
      game.resolve_choice!(life: 3)

      expect(p1.life).to eq(17)
      expect(p1.hand.count).to eq(hand_size + 3)
    end

    it "cannot pay more life than you have" do
      current_turn.end!
      game.resolve_choice!(life: 50)

      expect(p1.life).to eq(0)
    end

    it "does nothing when declined" do
      hand_size = p1.hand.count
      current_turn.end!
      game.skip_choice!

      expect(p1.life).to eq(20)
      expect(p1.hand.count).to eq(hand_size)
    end

    it "does nothing when paying zero" do
      hand_size = p1.hand.count
      current_turn.end!
      game.resolve_choice!(life: 0)

      expect(p1.life).to eq(20)
      expect(p1.hand.count).to eq(hand_size)
    end

    it "does not trigger at the opponent's end step" do
      go_to_main_phase_for!(p2)
      current_turn.end!

      expect(game.choices).to be_empty
    end
  end

  describe "your maximum hand size is five" do
    it "is five with it and seven without" do
      expect(p1.maximum_hand_size).to eq(7)
      ResolvePermanent("Necrodominance", owner: p1)

      expect(p1.maximum_hand_size).to eq(5)
    end

    it "does not change your opponent's" do
      ResolvePermanent("Necrodominance", owner: p1)

      expect(p2.maximum_hand_size).to eq(7)
    end
  end

  describe "graveyard replacement" do
    before do
      ResolvePermanent("Necrodominance", owner: p1)
      go_to_main_phase!
    end

    it "exiles a card that would be put into your graveyard" do
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
      bolt.discard!
      game.settle!

      expect(bolt.zone).to be_exile
      expect(p1.graveyard.cards).to be_empty
    end

    it "exiles your creature that dies" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.destroy!
      game.settle!

      expect(bears.card.zone).to be_exile
    end

    it "lets an opponent's cards go to their graveyard" do
      bolt = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
      bolt.discard!
      game.settle!

      expect(bolt.zone).to be_graveyard
    end
  end
end
