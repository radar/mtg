# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HerigastEruptingNullkite do
  include_context "two player game"

  let(:card) { Card("Herigast, Erupting Nullkite", owner: p1) }

  before { go_to_main_phase! }

  it "is a 6/6 flyer" do
    herigast = ResolvePermanent("Herigast, Erupting Nullkite", owner: p1)

    expect([herigast.power, herigast.toughness]).to eq([6, 6])
    expect(herigast.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
  end

  describe "emerge" do
    let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }

    before do
      p1.hand.add(card)
      p1.add_mana(red: 8)
    end

    def cast_with_emerge
      p1.cast_as(:alternative, card:) do |action|
        action.emerge(dreadmaw)
        action.pay_mana(red: 2)
      end
    end

    it "sacrifices a creature to reduce the emerge cost by its mana value" do
      cast_with_emerge

      expect(p1.graveyard.cards.map(&:name)).to include("Colossal Dreadmaw")
      expect(game.stack.spells.map { _1.card.name }).to include("Herigast, Erupting Nullkite")
    end
  end

  describe "granting emerge" do
    let!(:herigast) { ResolvePermanent("Herigast, Erupting Nullkite", owner: p1) }
    let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }
    let(:spell) { Card("Colossal Dreadmaw", owner: p1) }

    before do
      game.tick!
      p1.hand.add(spell)
      p1.add_mana(green: 2)
    end

    it "lets creature spells emerge at their own mana cost" do
      p1.cast(card: spell) do |action|
        action.emerge(herigast)
        action.pay_mana(green: 2)
      end

      expect(p1.graveyard.cards.map(&:name)).to include("Herigast, Erupting Nullkite")
    end

    it "does not apply to an opponent's spells" do
      opponent_spell = Card("Colossal Dreadmaw", owner: p2)
      p2.hand.add(opponent_spell)

      expect { p2.cast(card: opponent_spell) { _1.emerge(herigast) } }.to raise_error(/does not have emerge/)
    end
  end

  describe "cast trigger" do
    before do
      p1.hand.add(card)
      p1.add_mana(red: 9)
      p1.cast(card:) { _1.pay_mana(generic: { red: 9 }) }
      game.stack.resolve!
    end

    it "may exile your hand to draw three cards" do
      hand_before = p1.hand.cards.size
      game.resolve_choice!
      game.settle!

      expect(game.exile.cards.size).to eq(hand_before)
      expect(p1.hand.cards.size).to eq(3)
    end

    it "does nothing when declined" do
      hand_before = p1.hand.cards.size
      game.skip_choice!
      game.settle!

      expect(p1.hand.cards.size).to eq(hand_before)
    end
  end
end
