# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KindledFury do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gives target creature +1/+0 and first strike until end of turn" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Kindled Fury", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 2])
    expect(bears).to be_first_strike
  end

  it "wears off at end of turn" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Kindled Fury", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bears) }
    game.stack.resolve!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears.power).to eq(2)
    expect(bears).not_to be_first_strike
  end
end
