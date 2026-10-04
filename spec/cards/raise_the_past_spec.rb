# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RaiseThePast do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:raise_the_past) { Card("Raise The Past", owner: p1) }

  def cast_it
    p1.hand.add(raise_the_past)
    p1.add_mana(white: 4)
    cast_and_resolve(card: raise_the_past) { |a| a.pay_mana(white: 2, generic: { white: 2 }) }
  end

  it "returns every creature card with mana value 2 or less from your graveyard" do
    cub = Card("Grizzly Bears", owner: p1)
    ghoul = Card("Diregraf Ghoul", owner: p1)
    [cub, ghoul].each { p1.graveyard.add(_1) }
    cast_it

    expect(p1.creatures.map(&:card)).to contain_exactly(cub, ghoul)
    expect(p1.graveyard.cards).to contain_exactly(raise_the_past)
  end

  it "leaves behind creature cards with greater mana value, noncreature cards and the opponent's graveyard" do
    big = Card("Elvish Regrower", owner: p1)
    bolt = Card("Boltwave", owner: p1)
    theirs = Card("Grizzly Bears", owner: p2)
    p1.graveyard.add(big)
    p1.graveyard.add(bolt)
    p2.graveyard.add(theirs)
    cast_it

    expect(p1.creatures).to be_empty
    expect(p2.creatures).to be_empty
    expect(big.zone).to be_graveyard
    expect(bolt.zone).to be_graveyard
    expect(theirs.zone).to be_graveyard
  end

  it "does nothing with an empty graveyard" do
    cast_it

    expect(p1.creatures).to be_empty
  end
end
