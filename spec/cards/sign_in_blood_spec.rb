# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SignInBlood do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Sign In Blood", owner: p1).tap { p1.hand.add(_1) } }

  def cast_on(target)
    p1.add_mana(black: 2)
    p1.cast(card: spell) { _1.pay_mana(black: 2).targeting(target) }
    game.stack.resolve!
  end

  it "has target player draw two cards and lose 2 life" do
    hand = p1.hand.cards.count
    cast_on(p1)

    expect(p1.hand.cards.count).to eq(hand + 2) # the spell was added to hand and cast
    expect(p1.life).to eq(18)
  end

  it "can target an opponent" do
    cast_on(p2)

    expect(p2.life).to eq(18)
  end
end
