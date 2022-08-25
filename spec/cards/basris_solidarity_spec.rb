require 'spec_helper'

RSpec.describe Magic::Cards::BasrisSolidarity do
  include_context "two player game"

  subject { Card("Basri's Solidarity") }

  let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }
  let!(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", controller: p2) }

  it "adds a counter to each creature under p1's control" do
    cast_and_resolve(card: subject, player: p1)

    expect(wood_elves.counters.count).to eq(1)
    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)

    expect(loxodon_wayfarer.counters).to be_empty
  end
end
