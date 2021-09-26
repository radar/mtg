require 'spec_helper'

RSpec.describe "integration" do
  let(:game) { Magic::Game.new }
  let(:p1_library) do
    cards = [
      Magic::Cards::Forest.new,
      Magic::Cards::Forest.new,
      Magic::Cards::Forest.new,
      Magic::Cards::Forest.new,
      Magic::Cards::Forest.new,
      Magic::Cards::ChargeThrough.new,
      Magic::Cards::ChargeThrough.new,
      Magic::Cards::Forest.new,
    ]

    Magic::Library.new(cards)
  end
  let(:p1) { Magic::Player.new(library: p1_library) }

  before do
    7.times { p1.draw! }
  end

  it "plays a forest and charge through" do
    p1_forest = p1.hand.find { |card| card.name == "Forest" }
    p1.play!(p1_forest)
    p1_forest.tap!
    expect(p1.mana_pool[:green]).to eq(1)
    p1_charge_through = p1.hand.find { |card| card.name == "Charge Through" }
    expect(p1.can_cast?(p1_charge_through))
    p1.play!(p1_charge_through)
    expect(p1.hand.count).to eq(6)
  end
end
