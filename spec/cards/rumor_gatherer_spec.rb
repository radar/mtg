require "spec_helper"

RSpec.describe Magic::Cards::RumorGatherer do
  include_context "two player game"

  it "scries when the first creature enters" do
    ResolvePermanent("Rumor Gatherer", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(game.choices.last).to be_a(Magic::Choice::Scry)
  end

  it "draws when the second creature enters" do
    ResolvePermanent("Rumor Gatherer", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.skip_choice!
    hand_size = p1.hand.count
    ResolvePermanent("Raging Goblin", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end