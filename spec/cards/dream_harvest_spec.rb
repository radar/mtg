# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DreamHarvest do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Dream Harvest", owner: p1) }

  def cast_harvest
    p1.hand.add(card)
    p1.add_mana(blue: 7)
    p1.cast(card:) { _1.pay_mana(generic: { blue: 5 }, blue: 2) }
    game.stack.resolve!
  end

  it "exiles cards from the top of each opponent's library until their total mana value is 5 or more" do
    p2.library.to_a.each { p2.library.remove(_1) }
    [Card("Forest", owner: p2), Card("Courser Of Kruphix", owner: p2), Card("Courser Of Kruphix", owner: p2), Card("Mountain", owner: p2)]
      .reverse.each { p2.library.add(_1) }
    cards = p2.library.first(4)
    cast_harvest

    expect(cards.map { _1.zone.exile? }).to eq([true, true, true, false]) # 0 + 3 + 3 = 6
  end

  it "lets you cast the exiled nonland cards without paying their mana costs this turn" do
    p2.library.to_a.each { p2.library.remove(_1) }
    exiled = Card("Courser Of Kruphix", owner: p2)
    filler = Card("Courser Of Kruphix", owner: p2)
    [filler, exiled].each { p2.library.add(_1) } # exiled ends up on top
    cast_harvest
    p1.cast(card: exiled)
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Courser of Kruphix")
  end

  it "does not let the opponent cast them" do
    top = p2.library.first
    cast_harvest

    expect(game.play_permissions.permits?(top, p2)).to be(false)
  end

  it "the permission ends with the turn" do
    top = p2.library.first
    cast_harvest
    game.next_turn
    go_to_main_phase!

    expect(game.play_permissions.free_cast?(top, p1)).to be(false)
  end

  it "does not affect your own library" do
    top = p1.library.first
    cast_harvest

    expect(top.zone).to be_library
  end
end
