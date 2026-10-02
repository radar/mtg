# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StrixLookout do
  include_context "two player game"

  let!(:lookout) { ResolvePermanent("Strix Lookout", owner: p1) }

  it "is a 1/2 Bird with flying and vigilance" do
    expect([lookout.power, lookout.toughness]).to eq([1, 2])
    expect(lookout).to be_flying
    expect(lookout).to be_vigilant
  end

  it "draws a card then discards a card for {1}{U}, {T}" do
    hand_size = p1.hand.count
    p1.add_mana(blue: 2)
    p1.activate_ability(ability: lookout.activated_abilities.first) { _1.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!

    expect(lookout).to be_tapped
    expect(p1.hand.count).to eq(hand_size + 1)
    discarded = p1.hand.first
    game.resolve_choice!(card: discarded)

    expect(p1.hand.count).to eq(hand_size)
    expect(discarded.zone).to be_graveyard
  end
end
