# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RuggedPrairie do
  include_context "two player game"

  let!(:land) { ResolvePermanent("Rugged Prairie", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: land.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "pays {R} or {W} and taps to add {W}{W}" do
    p1.add_mana(red: 1)
    p1.activate_ability(ability: land.activated_abilities.last) do |a|
      a.choose(:white_white)
      a.pay_mana(red: 1)
    end

    expect(land).to be_tapped
    expect(p1.mana_pool[:white]).to eq(2)
    expect(p1.mana_pool[:red]).to eq(0)
  end

  it "adds {R}{W}" do
    p1.add_mana(white: 1)
    p1.activate_ability(ability: land.activated_abilities.last) do |a|
      a.choose(:red_white)
      a.pay_mana(white: 1)
    end

    expect([p1.mana_pool[:red], p1.mana_pool[:white]]).to eq([1, 1])
  end
end
