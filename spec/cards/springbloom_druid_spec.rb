require 'spec_helper'

RSpec.describe Magic::Cards::SpringbloomDruid do
  include_context "two player game"

  let!(:forest) { ResolvePermanent("Forest", owner: p1) }
  let(:basics) { 2.times.map { Card("Forest", owner: p1) } }

  before { basics.each { |c| p1.library.add(c) } }

  it "sacrifices a land and fetches up to two basics tapped" do
    ResolvePermanent("Springbloom Druid", owner: p1)
    game.resolve_choice!
    game.resolve_choice!(targets: basics)

    expect(p1.graveyard.cards.map(&:name)).to eq(["Forest"])
    expect(p1.lands.count).to eq(2)
    expect(p1.lands).to all(be_tapped)
  end

  it "lets the player choose which land to sacrifice" do
    island = ResolvePermanent("Island", owner: p1)
    ResolvePermanent("Springbloom Druid", owner: p1)

    expect(game.choices.first.method(:resolve!).parameters).to include([:key, :sacrifice])
    game.resolve_choice!(sacrifice: island)

    expect(p1.graveyard.cards.map(&:name)).to eq(["Island"])
    expect(forest.zone).to be_battlefield
  end

  it "does nothing when declined" do
    ResolvePermanent("Springbloom Druid", owner: p1)
    game.skip_choice!

    expect(forest.zone).to be_battlefield
    expect(p1.lands.count).to eq(1)
  end
end
