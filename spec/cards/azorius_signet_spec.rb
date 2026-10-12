# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AzoriusSignet do
  include_context "two player game"

  let!(:signet) { ResolvePermanent("Azorius Signet", owner: p1) }

  it "costs {2}" do
    expect(Card("Azorius Signet", owner: p1).mana_value).to eq(2)
  end

  it "pays {1} and taps to add {W}{U}" do
    p1.add_mana(green: 1)
    p1.activate_ability(ability: signet.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }) }

    expect(signet).to be_tapped
    expect(p1.mana_pool[:white]).to eq(1)
    expect(p1.mana_pool[:blue]).to eq(1)
    expect(p1.mana_pool[:green]).to eq(0)
  end
end
