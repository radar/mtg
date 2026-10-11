# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RakdosSignet do
  include_context "two player game"

  it "adds {B}{R} for {1} and tapping" do
    signet = ResolvePermanent("Rakdos Signet", owner: p1)
    p1.add_mana(green: 1)
    p1.activate_ability(ability: signet.activated_abilities.first) { _1.pay_mana(generic: { green: 1 }) }

    expect(p1.mana_pool[:black]).to eq(1)
    expect(p1.mana_pool[:red]).to eq(1)
    expect(signet).to be_tapped
  end
end
