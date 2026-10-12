# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LeylineOfTheVoid do
  include_context "two player game"

  # The Leyline is the top card of player one's library, so it is in their opening hand.
  def p1_library = [Card("Leyline Of The Void", owner: p1), *6.times.map { Card("Forest", owner: p1) }, *7.times.map { Card("Forest", owner: p1) }]

  let(:leyline) { p1.hand.cards.find { _1.name == "Leyline of the Void" } }

  describe "the opening hand" do
    it "offers to begin the game with it on the battlefield" do
      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::BeginOnBattlefield)
      expect(choice.card).to eq(leyline)
    end

    it "puts it onto the battlefield when accepted" do
      leyline # found in the opening hand
      game.resolve_choice!

      expect(p1.permanents.map(&:name)).to eq(["Leyline of the Void"])
      expect(leyline.zone).to be_battlefield
    end

    it "leaves it in hand when declined" do
      game.skip_choice!

      expect(leyline.zone).to be_hand
      expect(p1.permanents).to be_empty
    end
  end

  context "on the battlefield" do
    before do
      game.resolve_choice!
      go_to_main_phase!
    end

    it "exiles a card that would be put into an opponent's graveyard" do
      bolt = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
      bolt.discard!
      game.settle!

      expect(bolt.zone).to be_exile
      expect(p2.graveyard.cards).to be_empty
    end

    it "exiles an opponent's creature that dies" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bears.destroy!
      game.settle!

      expect(bears.card.zone).to be_exile
    end

    it "lets your own cards go to your graveyard" do
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
      bolt.discard!
      game.settle!

      expect(bolt.zone).to be_graveyard
    end
  end
end
