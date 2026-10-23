# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Crabomination do
  include_context "two player game"

  let(:card) { Card("Crabomination", owner: p1) }

  before { go_to_main_phase! }

  it "is a 5/5 Crab Demon" do
    crab = ResolvePermanent("Crabomination", owner: p1)

    expect([crab.power, crab.toughness]).to eq([5, 5])
  end

  describe "enters trigger" do
    let(:bears) { Card("Grizzly Bears", owner: p2) }
    let(:graveyard_card) { Card("Colossal Dreadmaw", owner: p2) }
    let(:hand_card) { Card("Grizzly Bears", owner: p2) }

    before do
      p2.hand.cards.to_a.dup.each { p2.hand.remove(_1) }
      p2.library.add(bears)
      p2.graveyard.add(graveyard_card)
      p2.hand.add(hand_card)
      ResolvePermanent("Crabomination", owner: p1)
      game.settle!
    end

    it "exiles the top of the library, a graveyard card and a hand card from the opponent" do
      expect(game.exile.cards).to contain_exactly(bears, graveyard_card, hand_card)
    end

    it "lets the controller cast one of them for free" do
      game.resolve_choice!(target: graveyard_card)
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Colossal Dreadmaw")
      expect(game.exile.cards).to contain_exactly(bears, hand_card)
    end

    it "lets the controller decline" do
      game.skip_choice!

      expect(game.exile.cards.size).to eq(3)
    end
  end

  describe "emerge from artifact" do
    let!(:artifact) { ResolvePermanent("Sol Ring", owner: p1) }

    before do
      p1.hand.add(card)
      p1.add_mana(black: 7)
    end

    it "sacrifices an artifact to reduce the cost by its mana value" do
      p1.cast_as(:alternative, card:) do |action|
        action.emerge(artifact)
        action.pay_mana(generic: { black: 4 }, black: 2)
      end

      expect(p1.graveyard.cards.map(&:name)).to include("Sol Ring")
    end

    it "refuses a non-artifact" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)

      expect { p1.cast_as(:alternative, card:) { _1.emerge(bears) } }.to raise_error(/not a valid emerge/)
    end
  end
end
