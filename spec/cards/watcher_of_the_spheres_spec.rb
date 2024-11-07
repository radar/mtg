require 'spec_helper'

RSpec.describe Magic::Cards::WatcherOfTheSpheres do
  include_context "two player game"

  let!(:watcher_of_the_spheres) { ResolvePermanent("Watcher Of The Spheres", owner: p1) }

  it "permanent has a static ability" do
    ability = watcher_of_the_spheres.static_abilities.first
    expect(ability).to be_a(Magic::Abilities::Static::ManaCostAdjustment)
  end

  context "when another creature with flying enters, add a +1/+1 counter" do
    before do
      ResolvePermanent("Aven Gagglemaster", owner: p1)
    end

    it "adds a +1/+1 buff" do
      game.tick!
      expect(watcher_of_the_spheres.power).to eq(3)
      expect(watcher_of_the_spheres.toughness).to eq(3)
    end
  end
end
