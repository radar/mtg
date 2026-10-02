# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VampiricRites do
  include_context "two player game"

  let!(:rites) { ResolvePermanent("Vampiric Rites", owner: p1) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "sacrifices a creature to gain 1 life and draw a card" do
    hand_size = p1.hand.count
    p1.add_mana(black: 2)
    p1.activate_ability(ability: rites.activated_abilities.first) do
      _1.pay_mana(generic: { black: 1 }, black: 1)
      _1.pay_sacrifice(elves)
    end
    game.stack.resolve!

    expect(p1.life).to eq(21)
    expect(p1.hand.count).to eq(hand_size + 1)
    expect(elves.card.zone).to be_graveyard
  end
end
