require "spec_helper"

RSpec.describe Magic::Cards::OrzhovBasilica do
  include_context "two player game"

  it "enters tapped and returns a land to its owner's hand" do
    forest = ResolvePermanent("Forest", owner: p1)
    basilica = ResolvePermanent("Orzhov Basilica", owner: p1)
    game.resolve_choice!(target: forest)

    expect(basilica).to be_tapped
    expect(p1.hand.by_name("Forest").count).to eq(8)
  end
end