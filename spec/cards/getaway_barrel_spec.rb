# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GetawayBarrel do
  include_context "two player game"

  def p1_library
    [
      *7.times.map { Card("Forest") },
      # End initial card draw
      Card("Mountain"),
      Card("Grizzly Bears"),
      *11.times.map { Card("Island") },
      Card("Swamp"),
      Card("Plains"),
    ]
  end

  let!(:barrel) { ResolvePermanent("Getaway Barrel", owner: p1) }

  it "does nothing when it leaves the battlefield other than to a graveyard" do
    barrel.exile!
    game.settle!
    expect(p1.library.count).to eq(15)
  end

  it "puts a random creature among the top thirteen onto the battlefield and the rest on the bottom" do
    barrel.destroy!
    game.settle!
    game.tick!

    bears = p1.creatures.find { _1.name == "Grizzly Bears" }
    expect(bears).not_to be_nil
    expect(p1.library.count).to eq(14)
    expect(p1.library.cards.map(&:name)).not_to include("Grizzly Bears")
    expect(p1.graveyard.cards.map(&:name)).to include("Getaway Barrel")
  end

  it "leaves cards past the thirteenth untouched" do
    barrel.destroy!
    game.settle!
    # The 14th and 15th cards (Swamp, Plains) were not revealed so they are now at the top.
    expect(p1.library.first(2).map(&:name)).to eq(%w[Swamp Plains])
  end

  it "puts nothing onto the battlefield when no creature is revealed" do
    p1.library.remove(p1.library.find { _1.name == "Grizzly Bears" })
    barrel.destroy!
    game.settle!
    expect(p1.creatures).to be_empty
  end
end
