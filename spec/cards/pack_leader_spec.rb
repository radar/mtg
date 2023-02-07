require 'spec_helper'

RSpec.describe Magic::Cards::PackLeader do
  include_context "two player game"

  let!(:pack_leader) { ResolvePermanent("Pack Leader", controller: p1) }
  let!(:alpine_watchdog) { ResolvePermanent("Alpine Watchdog", controller: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }

  it "buffs alpine watchdog" do
    expect(alpine_watchdog.power).to eq(3)
    expect(alpine_watchdog.toughness).to eq(3)
  end

  it "does not buff wood elves" do
    expect(wood_elves.power).to eq(1)
    expect(wood_elves.toughness).to eq(1)
  end

  it "does not buff itself" do
    expect(pack_leader.power).to eq(2)
    expect(pack_leader.toughness).to eq(2)
  end
end
