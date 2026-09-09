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
end