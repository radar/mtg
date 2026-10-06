# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IzzetSignet do
  include_context "two player game"

  let!(:signet) { ResolvePermanent("Izzet Signet", owner: p1) }

  it "pays {1} and taps to add {U}{R}" do
    p1.add_mana(green: 1)
    p1.activate_ability(ability: signet.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }) }

    expect(signet).to be_tapped
    expect(p1.mana_pool[:blue]).to eq(1)
    expect(p1.mana_pool[:red]).to eq(1)
  end
end
