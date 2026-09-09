require "spec_helper"

RSpec.describe Magic::Cards::OracleOfMulDaya do
  include_context "two player game"

  it "reveals the top card of its controller's library" do
    ResolvePermanent("Oracle of Mul Daya", owner: p1)

    expect(p1.library.first).to be_revealed
  end

  it "allows a land to be played from the top of the library" do
    oracle = ResolvePermanent("Oracle of Mul Daya", owner: p1)
    top_land = p1.library.first

    p1.play_land(land: top_land)

    expect(p1.lands.by_name(top_land.name).count).to eq(1)
    expect(oracle).to be_creature
  end
end