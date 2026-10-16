# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RefurbishedFamiliar do
  include_context "two player game"

  it "is a 2/1 flying Zombie Rat artifact creature" do
    familiar = ResolvePermanent("Refurbished Familiar", owner: p1)

    expect([familiar.power, familiar.toughness]).to eq([2, 1])
    expect(familiar.types.map(&:to_s)).to include("Artifact", "Creature")
    expect(familiar.flying?).to eq(true)
  end

  describe "affinity for artifacts" do
    before { go_to_main_phase! }

    def cast_with(artifact_count, owner: p1, paid_generic:)
      Array.new(artifact_count) { ResolvePermanent("Sol Ring", owner: owner) }
      card = Card("Refurbished Familiar", owner: p1)
      p1.hand.add(card)
      p1.add_mana(colorless: paid_generic, black: 1)
      p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: paid_generic }, black: 1) }
      game.stack.resolve!
      game.settle!
      card
    end

    it "costs {1} less for each artifact you control" do
      cast_with(2, paid_generic: 1)
      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Refurbished Familiar")
    end

    it "does not count an opponent's artifacts" do
      card = Card("Refurbished Familiar", owner: p1)
      p1.hand.add(card)
      ResolvePermanent("Sol Ring", owner: p2)
      p1.add_mana(colorless: 2, black: 1)
      expect { p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 2 }, black: 1) } }.to raise_error(StandardError)
    end
  end

  describe "enters trigger" do
    before { go_to_main_phase! }

    def enter
      ResolvePermanent("Refurbished Familiar", owner: p1)
      game.settle!
    end

    it "makes each opponent discard a card" do
      card = Card("Sol Ring", owner: p2)
      p2.hand.add(card)
      drawn_before = p1.hand.count
      enter
      expect(game.choices.first).to be_a(Magic::Choice::Discard)
      game.choices.first.resolve!(card: card)
      expect(p2.graveyard).to include(card)
      expect(p1.hand.count).to eq(drawn_before)
    end

    it "draws a card for you if the opponent has no cards in hand" do
      p2.hand.to_a.each { p2.hand.remove(_1) }
      expect(p2.hand.count).to eq(0)
      before_count = p1.hand.count
      enter
      expect(p1.hand.count).to eq(before_count + 1)
    end
  end
end
