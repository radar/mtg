require "spec_helper"

RSpec.describe Magic::Cards::CanyonSlough do
  include_context "two player game"

  it "can be cycled from hand for {2}" do
    card = Card("Canyon Slough", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 2)

    p1.cycle(card: card) { _1.pay_mana(generic: { black: 2 }) }

    expect(p1.graveyard.cards).to include(card)
  end

  it "has no cycling ability on the battlefield" do
    land = ResolvePermanent("Canyon Slough", owner: p1)

    expect(land.activated_abilities.map { _1.class.name }).not_to include(a_string_matching(/Cycling/))
  end
end
