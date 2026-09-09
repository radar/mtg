require "spec_helper"

RSpec.describe Magic::Cards::MoraugFuryOfAkoum do
  include_context "two player game"

  it "is a legendary creature" do
    expect(ResolvePermanent("Moraug, Fury Of Akoum", owner: p1)).to be_legendary
  end
end