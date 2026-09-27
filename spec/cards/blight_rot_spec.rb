# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BlightRot do
  include_context "two player game"

  it "puts four -1/-1 counters on target creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 3)

    p1.cast(card: Card("Blight Rot", owner: p1)) { |a| a.pay_mana(generic: { black: 2 }, black: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(4)
  end
end
