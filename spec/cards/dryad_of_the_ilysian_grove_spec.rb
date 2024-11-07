require "spec_helper"

RSpec.describe Magic::Cards::DryadOfTheIlysianGrove do
  include_context "two player game"

  subject { ResolvePermanent("Dryad of The Ilysian Grove") }

  it "has correct types" do
    expect(subject).to be_enchantment
    expect(subject).to be_creature
    expect(subject.type?("Nymph")).to eq(true)
    expect(subject.type?("Dryad")).to eq(true)
  end

  it "allows the player to play an additional land each turn" do
    subject

    expect(p1.max_lands_per_turn).to eq(2)
  end

  xit "gives the player access to all basic land types" do
    subject

    p1.play_land(land: p1.hand.by_name("Forest").first)

    forest = game.battlefield.by_name("Forest").first

    binding.pry
    expect(forest.type?("Plains")).to eq(true)
    expect(forest.type?("Island")).to eq(true)
    expect(forest.type?("Swamp")).to eq(true)
    expect(forest.type?("Mountain")).to eq(true)
    expect(forest.type?("Forest")).to eq(true)
    binding.pry
  end
end
