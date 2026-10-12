# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WaltzOfRage do
  include_context "two player game"

  let(:spell) { Card("Waltz Of Rage", owner: p1).tap { p1.hand.add(_1) } }
  let!(:big) { ResolvePermanent("Baneslayer Angel", owner: p1) } # 5/5
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def cast_on(creature)
    p1.add_mana(red: 5)
    p1.cast(card: spell) { _1.pay_mana(generic: { red: 3 }, red: 2).targeting(creature) }
    game.stack.resolve!
    game.settle!
  end

  it "has target creature you control deal damage equal to its power to each other creature" do
    cast_on(big)

    expect(theirs.zone).to be_nil
    expect(mine.zone).to be_nil
    expect(big.zone).to be_battlefield
    expect(big.damage).to eq(0)
  end

  it "exiles the top card of your library whenever a creature you control dies this turn, and lets you play it" do
    top = p1.library.first
    cast_on(big) # kills my Grizzly Bears too

    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to be(true)
  end

  it "does nothing for each creature your opponent loses" do
    library_size = p1.library.count
    cast_on(big)

    # Only my Grizzly Bears died among my creatures: exactly one card exiled.
    expect(p1.library.count).to eq(library_size - 1)
  end

  it "keeps triggering later in the turn" do
    cast_on(big)
    library_size = p1.library.count
    big.destroy!
    game.settle!

    expect(p1.library.count).to eq(library_size - 1)
  end

  it "stops at the end of the turn" do
    cast_on(big)
    current_turn.end!
    current_turn.cleanup!
    game.next_turn
    go_to_main_phase!
    library_size = p1.library.count
    big.destroy!
    game.settle!

    expect(p1.library.count).to eq(library_size)
  end

  it "doesn't trigger for an opponent's creature dying later" do
    cast_on(big)
    library_size = p1.library.count
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    other.destroy!
    game.settle!

    expect(p1.library.count).to eq(library_size)
  end
end
