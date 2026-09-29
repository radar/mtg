# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PummelerForHire do
  include_context "two player game"

  it "is a 4/4 Giant Mercenary with reach, vigilance and ward {2}" do
    pummeler = ResolvePermanent("Pummeler For Hire", owner: p1)
    expect([pummeler.power, pummeler.toughness]).to eq([4, 4])
    expect(pummeler).to be_reach
    expect(pummeler).to be_vigilant
    expect(pummeler.type?("Giant")).to eq(true)
  end

  it "gains life equal to the greatest power among Giants you control, itself included" do
    expect { ResolvePermanent("Pummeler For Hire", owner: p1) }.to change { p1.life }.by(4)
  end

  it "counts a bigger Giant you control" do
    ResolvePermanent("Axegrinder Giant", owner: p1) # 6/4
    expect { ResolvePermanent("Pummeler For Hire", owner: p1) }.to change { p1.life }.by(6)
  end

  it "ignores an opponent's Giants" do
    ResolvePermanent("Axegrinder Giant", owner: p2)
    expect { ResolvePermanent("Pummeler For Hire", owner: p1) }.to change { p1.life }.by(4)
  end
end
