# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EvisceratorsInsight do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:card) { Card("Eviscerator's Insight", owner: p1) }

  def cast(mode, mana:, payment:)
    p1.hand.add(card) unless mode == :flashback
    p1.add_mana(black: mana)
    p1.cast_as(mode, card:) do |a|
      a.pay_mana(**payment)
      a.pay_sacrifice(bears)
    end
    game.stack.resolve!
    game.settle!
  end

  it "sacrifices a creature as an additional cost and draws two cards" do
    hand = p1.hand.count
    cast(:normal, mana: 2, payment: { generic: { black: 1 }, black: 1 })

    expect(bears.card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand + 2)
  end

  it "can be cast from the graveyard with flashback, sacrificing again, then is exiled" do
    p1.graveyard.add(card)
    hand = p1.hand.count
    cast(:flashback, mana: 5, payment: { generic: { black: 4 }, black: 1 })

    expect(p1.hand.count).to eq(hand + 2)
    expect(card.zone).to be_a(Magic::Zones::Exile).or be_nil
  end
end
