# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SunscorchedDivide do
  include_context "two player game"

  let!(:land) { ResolvePermanent("Sunscorched Divide", owner: p1) }

  it "pays {1} and taps to add {R}{W}" do
    p1.add_mana(green: 1)
    p1.activate_ability(ability: land.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }) }

    expect(land).to be_tapped
    expect(p1.mana_pool[:red]).to eq(1)
    expect(p1.mana_pool[:white]).to eq(1)
  end
end
