# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RescueLeopard do
  include_context "two player game"

  let!(:leopard) { ResolvePermanent("Rescue Leopard", owner: p1) }

  it "is a 4/2" do
    expect([leopard.power, leopard.toughness]).to eq([4, 2])
  end

  context "when it becomes tapped" do
    before do
      leopard.tap!
      game.settle!
    end

    it "offers a may choice" do
      expect(game.choices.last).to be_a(described_class::BecomesTappedTrigger::MayChoice)
    end

    it "discards a card then draws a card if you accept" do
      game.resolve_choice!
      card = p1.hand.first
      hand = p1.hand.count
      game.resolve_choice!(card: card)

      expect(p1.graveyard.cards).to include(card)
      expect(p1.hand.count).to eq(hand)
    end

    it "does nothing if you decline" do
      hand = p1.hand.count
      game.skip_choice!
      expect(p1.hand.count).to eq(hand)
      expect(game.choices).to be_empty
    end
  end

  it "does not trigger when another creature becomes tapped" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.tap!
    game.settle!
    expect(game.choices).to be_empty
  end
end
