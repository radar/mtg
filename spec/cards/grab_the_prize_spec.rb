# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrabThePrize do
  include_context "two player game"

  subject(:grab_the_prize) { Card("Grab The Prize", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(grab_the_prize)
  end

  def cast_discarding(card)
    p1.add_mana(generic: 1, red: 1)
    p1.cast(card: grab_the_prize) do |action|
      action.pay_mana(generic: { generic: 1 }, red: 1)
      action.pay_discard(card)
    end
    game.stack.resolve!
    game.tick!
  end

  it "cannot be cast without discarding" do
    p1.add_mana(generic: 1, red: 1)
    expect do
      p1.cast(card: grab_the_prize) { |a| a.pay_mana(generic: { generic: 1 }, red: 1) }
    end.to raise_error("Additional costs have not been paid")
  end

  it "draws two and deals 2 damage to each opponent if a nonland card was discarded" do
    fodder = Card("Wood Elves", owner: p1)
    p1.hand.add(fodder)
    hand_before = p1.hand.count
    cast_discarding(fodder)
    expect(fodder.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand_before - 2 + 2)
    expect(p2.life).to eq(18)
  end

  it "deals no damage if a land was discarded" do
    fodder = Card("Island", owner: p1)
    p1.hand.add(fodder)
    cast_discarding(fodder)
    expect(p2.life).to eq(20)
  end
end
