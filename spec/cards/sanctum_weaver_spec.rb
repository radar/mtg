require "spec_helper"

RSpec.describe Magic::Cards::SanctumWeaver do
  include_context "two player game"

  it "adds mana equal to the number of enchantments you control" do
    weaver = ResolvePermanent("Sanctum Weaver", owner: p1)
    p1.activate_ability(ability: weaver.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(1)
  end
end