# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RebelliousStrike do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:strike) { Card("Rebellious Strike", owner: p1) }

  before do
    p1.hand.add(strike)
    p1.add_mana(white: 2)
  end

  it "gives target creature +3/+0 until end of turn and draws a card" do
    hand = p1.hand.count - 1
    p1.cast(card: strike) { |a| a.pay_mana(white: 1, generic: { white: 1 }).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([5, 2])
    expect(p1.hand.count).to eq(hand + 1)

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears.power).to eq(2)
  end

  it "can target an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    expect(strike.target_choices).to include(bears, theirs)
  end
end
