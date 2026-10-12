# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SmaugsFury do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_fury(target)
    card = Card("Smaugs Fury", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "gives +3/+0, reach and first strike" do
    cast_fury(bear)

    expect([bear.power, bear.toughness]).to eq([5, 2])
    expect(bear).to be_reach
    expect(bear).to be_first_strike
  end

  it "wears off at end of turn" do
    cast_fury(bear)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([bear.power, bear.toughness]).to eq([2, 2])
    expect(bear).not_to be_reach
    expect(bear).not_to be_first_strike
  end
end
