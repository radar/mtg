require "spec_helper"

RSpec.describe Magic::Cards::ZiatorasProvingGround do
  include_context "two player game"

  it "can be cycled from hand for {3}" do
    card = Card("Ziatora's Proving Ground", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 3)

    p1.cycle(card: card) { _1.pay_mana(generic: { red: 3 }) }

    expect(p1.graveyard.cards).to include(card)
  end

  it "has no cycling ability on the battlefield" do
    land = ResolvePermanent("Ziatora's Proving Ground", owner: p1)

    expect(land.activated_abilities.map { _1.class.name }).not_to include(a_string_matching(/Cycling/))
  end
end
