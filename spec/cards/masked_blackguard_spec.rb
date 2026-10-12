# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MaskedBlackguard do
  include_context "two player game"

  let!(:blackguard) { ResolvePermanent("Masked Blackguard", owner: p1) }

  it "is a 2/1 Human Rogue with flash" do
    expect([blackguard.power, blackguard.toughness]).to eq([2, 1])
    expect(blackguard.has_keyword?(Magic::Cards::Keywords::FLASH)).to eq(true)
  end

  it "gets +1/+1 until end of turn for {2}{B}" do
    p1.add_mana(black: 3)
    p1.activate_ability(ability: blackguard.activated_abilities.first) { _1.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.tick!

    expect([blackguard.power, blackguard.toughness]).to eq([3, 2])
  end

  it "can be cast at instant speed" do
    card = Card("Masked Blackguard", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 2)

    expect { p1.cast(card:) { _1.pay_mana(generic: { black: 1 }, black: 1) } }.not_to raise_error
  end
end
