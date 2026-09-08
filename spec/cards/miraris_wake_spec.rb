require "spec_helper"

RSpec.describe Magic::Cards::MirarisWake do
  include_context "two player game"

  it "gives creatures +1/+1" do
    ResolvePermanent("Mirari's Wake", owner: p1)
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(creature.power).to eq(3)
    expect(creature.toughness).to eq(3)
  end

  it "adds one mana when a land produces mana" do
    ResolvePermanent("Mirari's Wake", owner: p1)
    land = ResolvePermanent("Forest", owner: p1)

    p1.activate_ability(ability: land.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(2)
  end
end