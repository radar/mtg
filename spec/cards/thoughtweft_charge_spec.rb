# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThoughtweftCharge do
  include_context "two player game"

  let(:card) { Card("Thoughtweft Charge", owner: p1) }

  def cast_on(target)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "gives a creature +3/+3 until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_on(bears)

    expect([bears.power, bears.toughness]).to eq([5, 5])
  end

  it "does not draw a card when no creature entered under your control this turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    hand = p1.hand.count
    cast_on(bears)

    expect(p1.hand.count).to eq(hand) # the spell left the hand, nothing drawn
  end

  it "draws a card if a creature entered the battlefield under your control this turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    hand = p1.hand.count
    cast_on(bears)

    expect(p1.hand.count).to eq(hand + 1) # the spell left the hand, one card drawn
  end

  it "does not count a creature that entered under an opponent's control" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    target = ResolvePermanent("Courser Of Kruphix", owner: p2)
    p1.hand.add(card)
    hand_before = p1.hand.count
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(target) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_before - 1)
  end
end
