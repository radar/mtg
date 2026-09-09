require "spec_helper"

RSpec.describe Magic::Cards::GodEternalBontu do
  include_context "two player game"

  it "is a legendary Zombie God with menace" do
    bontu = ResolvePermanent("God-Eternal Bontu", owner: p1)

    expect(bontu).to be_legendary
    expect(bontu).to be_creature
    expect(bontu.has_keyword?(:menace)).to be(true)
  end
end