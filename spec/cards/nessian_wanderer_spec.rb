require "spec_helper"

RSpec.describe Magic::Cards::NessianWanderer do
  include_context "two player game"

  it "offers a land from the top three after an enchantment enters" do
    initial_land_count = p1.hand.lands.count
    wanderer = ResolvePermanent("Nessian Wanderer", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    choice = game.choices.last
    expect(choice).to be_a(described_class::LandChoice)
    game.resolve_choice!(target: choice.choices.first)

    expect(p1.hand.lands.count).to eq(initial_land_count + 1)
    expect(wanderer).to be_creature
  end
end