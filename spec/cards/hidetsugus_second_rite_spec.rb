# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HidetsugusSecondRite do
  include_context "two player game"

  let(:spell) { Card("Hidetsugus Second Rite", owner: p1) }

  def cast_at(target)
    p1.hand.add(spell)
    p1.add_mana(red: 4)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 3 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "is a {3}{R} instant" do
    expect(spell.cost.cost).to eq(generic: 3, red: 1)
    expect(spell).to be_a(Magic::Cards::Instant)
  end

  it "deals 10 damage to a player with exactly 10 life" do
    p2.lose_life(10)
    cast_at(p2)

    expect(p2.life).to eq(0)
    expect(p2).to be_lost
  end

  it "can target yourself, with exactly 10 life" do
    p1.lose_life(10)
    cast_at(p1)

    expect(p1.life).to eq(0)
  end

  it "does nothing to a player with more than 10 life" do
    p2.lose_life(9)
    cast_at(p2)

    expect(p2.life).to eq(11)
  end

  it "does nothing to a player with less than 10 life" do
    p2.lose_life(11)
    cast_at(p2)

    expect(p2.life).to eq(9)
  end
end
