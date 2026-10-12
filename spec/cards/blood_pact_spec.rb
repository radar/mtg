# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloodPact do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Blood Pact", owner: p1).tap { p1.hand.add(_1) } }

  def cast_on(target)
    p1.add_mana(black: 3)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 2 }, black: 1).targeting(target) }
    game.stack.resolve!
  end

  it "has target player draw two cards and lose 2 life" do
    hand = p2.hand.cards.count
    cast_on(p2)

    expect(p2.hand.cards.count).to eq(hand + 2)
    expect(p2.life).to eq(18)
  end

  it "can target yourself" do
    hand = p1.hand.cards.count
    cast_on(p1)

    expect(p1.hand.cards.count).to eq(hand + 2) # the spell was added to hand and cast
    expect(p1.life).to eq(18)
  end
end
