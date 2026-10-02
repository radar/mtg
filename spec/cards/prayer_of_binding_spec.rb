# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrayerOfBinding do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_rival) { ResolvePermanent("Bear Cub", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  let!(:prayer) { ResolvePermanent("Prayer Of Binding", owner: p1) }

  it "exiles up to one target nonland permanent an opponent controls and gains you 2 life" do
    game.resolve_choice!(target: rival)

    expect(game.exile.cards).to include(rival.card)
    expect(p1.life).to eq(22)
  end

  it "can't target your own permanents" do
    expect(game.choices.last.choices).not_to include(mine)
  end

  it "returns the exiled permanent when it leaves the battlefield" do
    game.resolve_choice!(target: rival)
    prayer.destroy!
    game.settle!

    expect(game.exile.cards).not_to include(rival.card)
    expect(p2.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "still gains you 2 life when you decline to exile anything" do
    game.skip_choice!

    expect(p1.life).to eq(22)
    expect(other_rival.zone).to be_battlefield
  end
end
