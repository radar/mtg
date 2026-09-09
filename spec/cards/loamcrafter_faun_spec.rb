require "spec_helper"

RSpec.describe Magic::Cards::LoamcrafterFaun do
  include_context "two player game"

  it "lets you discard lands and choose specific nonland graveyard cards" do
    faun = ResolvePermanent("Loamcrafter Faun", owner: p1)
    land = Card("Forest", owner: p1)
    target = Card("Mind Stone", owner: p1)
    other_target = Card("Spirited Companion", owner: p1)
    p1.hand.add(land)
    p1.graveyard.add(target)
    p1.graveyard.add(other_target)
    game.resolve_choice!(targets: [land])

    choice = game.choices.last
    expect(choice.choices).to include(target)
    game.resolve_choice!(targets: [target])

    expect(target.zone).to be_hand
    expect(faun).to be_creature
  end
end