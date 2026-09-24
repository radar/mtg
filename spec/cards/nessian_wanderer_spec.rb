require "spec_helper"

RSpec.describe Magic::Cards::NessianWanderer do
  include_context "two player game"

  it "offers a land from the top three after an enchantment enters" do
    initial_land_count = p1.hand.lands.count
    wanderer = ResolvePermanent("Nessian Wanderer", owner: p1)
    # A pure Enchantment with no ETB effect of its own -- Spirited Companion's own
    # "draw a card" ETB trigger is simultaneous with (and same-controller as)
    # Wanderer's own trigger here, and the engine has no real priority yet to force
    # a specific order between a player's own simultaneous triggers (either order
    # is rules-legal), so it'd make this test's outcome depend on that ordering.
    ResolvePermanent("Doubling Season", owner: p1)

    choice = game.choices.last
    expect(choice).to be_a(described_class::LandChoice)
    game.resolve_choice!(target: choice.choices.first)

    expect(p1.hand.lands.count).to eq(initial_land_count + 1)
    expect(wanderer).to be_creature
  end
end