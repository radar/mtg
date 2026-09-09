require "spec_helper"

RSpec.describe Magic::Cards::SzarelGenesisShepherd do
  include_context "two player game"

  it "is legendary and flying" do
    shepherd = ResolvePermanent("Szarel, Genesis Shepherd", owner: p1)

    expect(shepherd).to be_legendary
    expect(shepherd).to be_flying
  end
end