require "spec_helper"

RSpec.describe Magic::Cards::SelesnyaSanctuary do
  include_context "two player game"

  it "enters tapped and returns a land to hand" do
    forest = ResolvePermanent("Forest", owner: p1)
    sanctuary = ResolvePermanent("Selesnya Sanctuary", owner: p1)
    game.resolve_choice!(target: forest)

    expect(sanctuary).to be_tapped
    expect(p1.hand.by_name("Forest").count).to eq(8)
  end

  it "taps for {G}{W}" do
    sanctuary = ResolvePermanent("Selesnya Sanctuary", owner: p1)
    sanctuary.untap!
    p1.activate_ability(ability: sanctuary.activated_abilities.first)

    expect(p1.mana_pool[:green]).to eq(1)
    expect(p1.mana_pool[:white]).to eq(1)
  end
end