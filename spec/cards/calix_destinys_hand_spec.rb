require "spec_helper"

RSpec.describe Magic::Cards::CalixDestinysHand do
  include_context "two player game"

  it "enters with four loyalty" do
    planeswalker = ResolvePermanent("Calix, Destiny's Hand", owner: p1)

    expect(planeswalker.loyalty).to eq(4)
  end
end