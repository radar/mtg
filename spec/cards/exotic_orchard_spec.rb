require "spec_helper"

RSpec.describe Magic::Cards::ExoticOrchard do
  include_context "two player game"

  it "produces a color an opponent's land can produce" do
    ResolvePermanent("Mountain", owner: p2)
    orchard = ResolvePermanent("Exotic Orchard", owner: p1)
    p1.activate_ability(ability: orchard.activated_abilities.first) { _1.choose(:red) }

    expect(p1.mana_pool[:red]).to eq(1)
  end
end