# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FleetingDistraction do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "gives target creature -1/-0 until end of turn and draws a card" do
    hand_size = p1.hand.count
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Fleeting Distraction", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(rival) }
    game.stack.resolve!
    game.tick!

    expect([rival.power, rival.toughness]).to eq([1, 2])
    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "wears off at end of turn" do
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Fleeting Distraction", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(rival) }
    game.stack.resolve!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(rival.power).to eq(2)
  end
end
