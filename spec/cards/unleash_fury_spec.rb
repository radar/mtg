# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnleashFury do
  include_context "two player game"

  let!(:angel) { ResolvePermanent("Serra Angel", owner: p1) } # 4/4

  def cast(target)
    card = Card("Unleash Fury", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "doubles the power of the target creature" do
    cast(angel)

    expect([angel.power, angel.toughness]).to eq([8, 4])
  end

  it "doubles the current power, including earlier pumps" do
    angel.modify_power(2)
    game.tick!
    cast(angel)

    expect(angel.power).to eq(12)
  end

  it "wears off at end of turn" do
    cast(angel)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(angel.power).to eq(4)
  end
end
