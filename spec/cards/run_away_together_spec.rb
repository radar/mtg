# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RunAwayTogether do
  include_context "two player game"

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:also_mine) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast(*targets)
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Run Away Together", owner: p1)) do
      _1.pay_mana(blue: 1, generic: { blue: 1 })
      _1.targeting(*targets)
    end
    game.stack.resolve!
  end

  it "returns two creatures controlled by different players to their owners' hands" do
    cast(mine, theirs)
    expect(mine.card.zone).to be_hand
    expect(theirs.card.zone).to be_hand
    expect(p1.hand.cards).to include(mine.card)
    expect(p2.hand.cards).to include(theirs.card)
  end

  it "can't target two creatures controlled by the same player" do
    expect { cast(mine, also_mine) }.to raise_error(Magic::Actions::Cast::InvalidTarget, /Invalid targets/)
    expect(mine.zone).to be_battlefield
  end

  it "can't target the same creature twice" do
    expect { cast(mine, mine) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "returns a stolen creature to its owner's hand, not the controller's" do
    theirs.controller = p1
    stolen_and_mine = [theirs, ResolvePermanent("Grizzly Bears", owner: p2)]
    cast(*stolen_and_mine)
    expect(p2.hand.cards).to include(theirs.card)
  end
end
