# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HareApparent do
  include_context "two player game"
  before { go_to_main_phase! }

  def rabbits(player = p1) = player.creatures.select { _1.name == "Rabbit" }

  it "is a 2/2 Rabbit Noble" do
    hare = ResolvePermanent("Hare Apparent", owner: p1)

    expect([hare.power, hare.toughness]).to eq([2, 2])
    expect(hare.type?("Noble")).to eq(true)
  end

  it "creates no Rabbits when it is the only Hare Apparent" do
    ResolvePermanent("Hare Apparent", owner: p1)

    expect(rabbits).to be_empty
  end

  it "creates one 1/1 white Rabbit per other Hare Apparent you control" do
    2.times { ResolvePermanent("Hare Apparent", owner: p1) }
    expect(rabbits.size).to eq(1)

    ResolvePermanent("Hare Apparent", owner: p1)
    expect(rabbits.size).to eq(1 + 2)
    expect([rabbits.first.power, rabbits.first.toughness]).to eq([1, 1])
    expect(rabbits.first.colors).to eq([:white])
  end

  it "doesn't count the opponent's Hare Apparents or other creatures" do
    ResolvePermanent("Hare Apparent", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Hare Apparent", owner: p1)

    expect(rabbits).to be_empty
  end
end
