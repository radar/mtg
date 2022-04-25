require 'spec_helper'

RSpec.describe Magic::Cards::PackLeader do
  include_context "two player game"

  let(:pack_leader) { Card("Pack Leader", controller: p1) }
  let(:alpine_watchdog) { Card("Alpine Watchdog", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p1) }

  before do
    game.battlefield.add(pack_leader)
    game.battlefield.add(alpine_watchdog)
  end

  it "adds a static buff ability" do
    ability = game.battlefield.static_abilities.first
    expect(ability).to be_a(Magic::Abilities::Static::CreaturesGetBuffed)
  end

  it "buffs alpine watchdog" do
    expect(alpine_watchdog.power).to eq(3)
    expect(alpine_watchdog.toughness).to eq(3)
  end

  it "does not buff wood elves" do
    expect(wood_elves.power).to eq(1)
    expect(wood_elves.toughness).to eq(1)
  end
end
