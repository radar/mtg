require "spec_helper"

RSpec.describe Magic::Cards::TitaniaProtectorOfArgoth do
  include_context "two player game"

  it "returns a land from your graveyard when it enters" do
    land = Card("Forest", owner: p1)
    p1.graveyard.add(land)
    ResolvePermanent("Titania, Protector Of Argoth", owner: p1)

    game.resolve_choice!(target: land)

    expect(p1.lands.by_name("Forest").count).to eq(1)
  end

  it "creates an Elemental when your land goes to the graveyard" do
    ResolvePermanent("Titania, Protector Of Argoth", owner: p1)
    land = ResolvePermanent("Forest", owner: p1)
    land.sacrifice!

    expect(p1.creatures.by_name("Elemental").count).to eq(1)
  end
end