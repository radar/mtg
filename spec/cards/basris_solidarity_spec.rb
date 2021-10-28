require 'spec_helper'

RSpec.describe Magic::Cards::BasrisSolidarity do
  include_context "two player game"

  subject { Card("Basri's Solidarity", controller: p1) }

  let(:wood_elves) { Card("Wood Elves", controller: p1) }
  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", controller: p2) }

  before do
    game.battlefield.add(wood_elves)
    game.battlefield.add(loxodon_wayfarer)
  end

  it "adds a counter to each creature under p1's control" do
    subject.cast!
    game.stack.resolve!
    expect(wood_elves.counters.count).to eq(1)
    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)

    expect(loxodon_wayfarer.counters).to be_empty
  end
end
