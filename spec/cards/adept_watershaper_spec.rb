# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AdeptWatershaper do
  include_context "two player game"

  let!(:watershaper) { ResolvePermanent("Adept Watershaper", owner: p1) }

  it "is a 3/4 Merfolk Cleric" do
    expect([watershaper.power, watershaper.toughness]).to eq([3, 4])
  end

  it "gives other tapped creatures you control indestructible" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.tap!
    game.tick!

    expect(bears).to be_indestructible
  end

  it "does not give it to untapped creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(bears).not_to be_indestructible
  end

  it "stops when the creature untaps" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.tap!
    game.tick!
    bears.untap!
    game.tick!

    expect(bears).not_to be_indestructible
  end

  it "does not apply to itself or to the opponent's creatures" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    theirs.tap!
    watershaper.tap!
    game.tick!

    expect(theirs).not_to be_indestructible
    expect(watershaper).not_to be_indestructible
  end
end
