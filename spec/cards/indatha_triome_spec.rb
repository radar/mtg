require "spec_helper"

RSpec.describe Magic::Cards::IndathaTriome do
  include_context "two player game"

  it "enters tapped and taps for white, black, or green" do
    triome = ResolvePermanent("Indatha Triome", owner: p1)
    triome.untap!
    p1.activate_ability(ability: triome.activated_abilities.first) { _1.choose(:green) }

    expect(triome).to be_tapped
    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "cycles for {3}" do
    triome = Card("Indatha Triome", owner: p1)
    p1.hand.add(triome)
    p1.add_mana(colorless: 3)
    top_card = p1.library.first

    p1.cycle(card: triome) { _1.pay_mana(generic: { colorless: 3 }) }

    expect(triome.zone).to be_graveyard
    expect(p1.hand).to include(top_card)
  end
end
