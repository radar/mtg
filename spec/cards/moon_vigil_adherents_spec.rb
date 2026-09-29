# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoonVigilAdherents do
  include_context "two player game"

  let!(:adherents) { ResolvePermanent("Moon Vigil Adherents", owner: p1) }

  before { game.tick! }

  it "has trample and counts itself: 1/1 alone" do
    expect(adherents).to be_trample
    expect([adherents.power, adherents.toughness]).to eq([1, 1])
  end

  it "gets +1/+1 for each other creature you control" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
    game.tick!
    expect([adherents.power, adherents.toughness]).to eq([3, 3])
  end

  it "gets +1/+1 for each creature card in your graveyard, not other cards or the opponent's" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    p1.graveyard.add(Card("Lightning Bolt", owner: p1))
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!
    expect([adherents.power, adherents.toughness]).to eq([2, 2])
  end

  it "shrinks when a creature dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    expect(adherents.power).to eq(2)

    bears.destroy!
    game.tick!
    # the Bears left the battlefield but is now a creature card in the graveyard
    expect(adherents.power).to eq(2)
  end
end
