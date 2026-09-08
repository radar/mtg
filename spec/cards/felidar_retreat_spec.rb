require "spec_helper"

RSpec.describe Magic::Cards::FelidarRetreat do
  include_context "two player game"

  let!(:retreat) { ResolvePermanent("Felidar Retreat", owner: p1) }
  let(:forest) { Card("Forest", owner: p1) }

  it "offers a Cat Beast token after landfall" do
    p1.hand.add(forest)
    p1.play_land(land: forest)
    game.resolve_choice!(mode: :token)

    expect(p1.creatures.by_name("Cat Beast").count).to eq(1)
  end

  it "puts a counter on each creature and grants vigilance" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(forest)
    p1.play_land(land: forest)
    game.resolve_choice!(mode: :counter)
    game.tick!

    expect(creature.counters.count).to eq(1)
    expect(creature).to be_vigilant
  end
end