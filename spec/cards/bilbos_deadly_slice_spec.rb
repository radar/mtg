# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BilbosDeadlySlice do
  include_context "two player game"

  it "destroys target creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    slice = Card("Bilbo's Deadly Slice", owner: p1)
    p1.add_mana(black: 3)
    cast_and_resolve(card: slice, player: p1, targeting: bears) { |a| a.pay_mana(generic: { black: 1 }, black: 2) }

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end
end
