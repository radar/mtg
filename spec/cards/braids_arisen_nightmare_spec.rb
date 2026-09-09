require "spec_helper"

RSpec.describe Magic::Cards::BraidsArisenNightmare do
  include_context "two player game"

  it "offers an optional sacrifice at end step" do
    braids = ResolvePermanent("Braids, Arisen Nightmare", owner: p1)
    target = ResolvePermanent("Grizzly Bears", owner: p1)
    current_turn.end!

    expect(game.choices.last).to be_a(described_class::EndStepChoice)
    game.resolve_choice!(target: target)

    expect(target.card.zone).to be_graveyard
    expect(braids).to be_creature
  end

  it "lets an opponent decline and causes life loss and a draw" do
    ResolvePermanent("Braids, Arisen Nightmare", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    opponent_creature = ResolvePermanent("Grizzly Bears", owner: p2)
    hand_size = p1.hand.count
    current_turn.end!
    game.resolve_choice!(target: p1.creatures.by_name("Grizzly Bears").first)
    game.skip_choice!

    expect(game.battlefield).to include(opponent_creature)
    expect(p2.life).to eq(18)
    expect(p1.hand.count).to eq(hand_size + 1)
  end
end