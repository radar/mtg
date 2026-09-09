require "spec_helper"

RSpec.describe Magic::Cards::BolassCitadel do
  include_context "two player game"

  it "is a legendary artifact" do
    citadel = ResolvePermanent("Bolas's Citadel", owner: p1)

    expect(citadel).to be_artifact
    expect(citadel).to be_legendary
  end
end