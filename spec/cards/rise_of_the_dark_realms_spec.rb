# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RiseOfTheDarkRealms do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:rise) { Card("Rise Of The Dark Realms", owner: p1) }

  def cast_it
    p1.hand.add(rise)
    p1.add_mana(black: 9)
    cast_and_resolve(card: rise) { |a| a.pay_mana(black: 2, generic: { black: 7 }) }
  end

  it "puts every creature card from all graveyards onto the battlefield under your control" do
    mine = Card("Grizzly Bears", owner: p1)
    theirs = Card("Elvish Regrower", owner: p2)
    bolt = Card("Boltwave", owner: p2)
    p1.graveyard.add(mine)
    p2.graveyard.add(theirs)
    p2.graveyard.add(bolt)
    cast_it

    expect(p1.creatures.map(&:card)).to contain_exactly(mine, theirs)
    expect(p2.creatures).to be_empty
    expect(p1.creatures.find { _1.card == theirs }.controller).to eq(p1)
    expect(theirs.owner).to eq(p2)
    expect(bolt.zone).to be_graveyard
  end
end
