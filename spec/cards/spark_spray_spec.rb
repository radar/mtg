# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SparkSpray do
  include_context "two player game"

  it "deals 1 damage to target creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 1)
    p1.cast(card: Card("Spark Spray", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bear) }

    game.stack.resolve!

    expect(bear.damage).to eq(1)
  end

  it "deals 1 damage to a player" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Spark Spray", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }

    game.stack.resolve!

    expect(p2.life).to eq(19)
  end

  context "cycling" do
    it "discards the card and draws a card for {R}" do
      card = Card("Spark Spray", owner: p1)
      p1.hand.add(card)
      p1.add_mana(red: 1)

      expect { p1.cycle(card: card) { |a| a.pay_mana(red: 1) } }.to change { p1.hand.count }.by(0)

      expect(card.zone).to be_graveyard
    end

    it "draws a card" do
      card = Card("Spark Spray", owner: p1)
      p1.hand.add(card)
      p1.add_mana(red: 1)
      top_card = p1.library.first

      p1.cycle(card: card) { |a| a.pay_mana(red: 1) }

      expect(p1.hand).to include(top_card)
    end
  end
end
