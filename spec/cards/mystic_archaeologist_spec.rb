# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MysticArchaeologist do
  include_context "two player game"

  let!(:archaeologist) { ResolvePermanent("Mystic Archaeologist", owner: p1) }

  it "is a 2/1 Human Wizard" do
    expect([archaeologist.power, archaeologist.toughness]).to eq([2, 1])
  end

  it "draws two cards for {3}{U}{U}" do
    hand_size = p1.hand.count
    p1.add_mana(blue: 5)
    p1.activate_ability(ability: archaeologist.activated_abilities.first) { _1.pay_mana(generic: { blue: 3 }, blue: 2) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_size + 2)
  end
end
