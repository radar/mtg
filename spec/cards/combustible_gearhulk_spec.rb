# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CombustibleGearhulk do
  include_context "two player game"

  def enter_gearhulk!
    ResolvePermanent("Combustible Gearhulk", owner: p1)
    game.settle!
  end

  it "is a 6/6 first strike artifact creature" do
    gearhulk = ResolvePermanent("Combustible Gearhulk", owner: p1)

    expect(gearhulk).to be_artifact
    expect(gearhulk).to be_creature
    expect([gearhulk.power, gearhulk.toughness]).to eq([6, 6])
    expect(gearhulk).to have_keyword(:first_strike)
  end

  it "draws you three cards when the opponent allows it" do
    hand = p1.hand.cards.count
    enter_gearhulk!
    game.resolve_choice! # yes

    expect(p1.hand.cards.count).to eq(hand + 3)
  end

  it "mills three and deals damage equal to their total mana value when the opponent declines" do
    p1.library.add(Card("Grizzly Bears", owner: p1)) # mana value 2
    p1.library.add(Card("Forest", owner: p1))
    p1.library.add(Card("Lightning Bolt", owner: p1)) # mana value 1
    lib = p1.library.count
    enter_gearhulk!
    game.skip_choice!
    game.settle!

    expect(p1.library.count).to eq(lib - 3)
    expect(p2.life).to eq(17)
  end

  it "deals no damage when the milled cards are all lands" do
    3.times { p1.library.add(Card("Forest", owner: p1)) }
    enter_gearhulk!
    game.skip_choice!
    game.settle!

    expect(p2.life).to eq(20)
  end
end
