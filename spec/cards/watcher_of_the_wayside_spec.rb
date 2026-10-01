# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WatcherOfTheWayside do
  include_context "two player game"

  let!(:watcher) { ResolvePermanent("Watcher Of The Wayside", owner: p1) }

  it "is a 3/2 artifact Golem" do
    expect(watcher).to be_artifact
    expect(watcher.type?("Golem")).to eq(true)
    expect([watcher.power, watcher.toughness]).to eq([3, 2])
  end

  it "lets you pick a player to mill two cards, and you gain 2 life" do
    choice = game.choices.last
    expect(choice.choices).to include(p1, p2)

    game.resolve_choice!(target: p2)
    expect(p2.graveyard.count).to eq(2)
    expect(p1.life).to eq(22)
  end

  it "can mill yourself" do
    game.resolve_choice!(target: p1)
    expect(p1.graveyard.count).to eq(2)
  end
end
