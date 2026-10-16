# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RefurbishedFamiliar do
  include_context "two player game"

  it "is a 2/1 flying Zombie Rat artifact creature" do
    familiar = ResolvePermanent("Refurbished Familiar", owner: p1)

    expect([familiar.power, familiar.toughness]).to eq([2, 1])
    expect(familiar.types.map(&:to_s)).to include("Artifact", "Creature")
    expect(familiar.types.map(&:to_s)).to include("Zombie", "Rat")
    expect(familiar.card.cost.cost).to eq(generic: 3, black: 1)
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
      expect { p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 2 }, black: 1) } }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(game.battlefield.controlled_by(p1).map(&:name)).not_to include("Refurbished Familiar")
    end

    it "costs the full {3}{B} with no artifacts" do
      cast_with(0, paid_generic: 3)
      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Refurbished Familiar")
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

    context "with three players" do
      let(:p3) { Magic::Player.new(name: "P3") }
      let(:p4) { Magic::Player.new(name: "P4") }

      before do
        game.add_player(p3)
        game.add_player(p4)
      end

      it "makes each opponent with cards discard, and draws once per opponent with an empty hand" do
        p2.hand.to_a.each { p2.hand.remove(_1) }
        p3.hand.to_a.each { p3.hand.remove(_1) }
        p4.hand.to_a.each { p4.hand.remove(_1) }
        card = Card("Sol Ring", owner: p4)
        p4.hand.add(card)
        before_count = p1.hand.count
        enter
        discards = game.choices.select { _1.is_a?(Magic::Choice::Discard) }
        expect(discards.map(&:player)).to eq([p4])
        discards.first.resolve!(card: card)
        expect(p4.graveyard).to include(card)
        expect(p1.hand.count).to eq(before_count + 2)
      end
    end
  end
end
