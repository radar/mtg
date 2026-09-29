# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GallantFowlknight do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:kithkin) { ResolvePermanent("Timid Shieldbearer", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  subject!(:fowlknight) { ResolvePermanent("Gallant Fowlknight", owner: p1) }

  before { game.tick! }

  it "is a 3/4 Kithkin Knight" do
    expect([fowlknight.power, fowlknight.toughness]).to eq([4, 4])
    expect(fowlknight.type?("Kithkin")).to eq(true)
  end

  it "gives creatures you control +1/+0 until end of turn, itself included" do
    expect(bears.power).to eq(3)
    expect(fowlknight.power).to eq(4)
    expect(rival.power).to eq(2)
  end

  it "gives Kithkin first strike too, but not other creatures" do
    expect(kithkin).to be_first_strike
    expect(fowlknight).to be_first_strike
    expect(bears).not_to be_first_strike
  end

  it "wears off at end of turn" do
    [fowlknight, kithkin, bears].each(&:cleanup!)
    expect(fowlknight.power).to eq(3)
    expect(kithkin).not_to be_first_strike
  end
end
