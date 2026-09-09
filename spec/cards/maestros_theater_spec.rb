require "spec_helper"

RSpec.describe Magic::Cards::MaestrosTheater do
  include_context "two player game"

  it "sacrifices itself when it enters" do
    ResolvePermanent("Maestros Theater", owner: p1)

    expect(p1.graveyard.by_name("Maestros Theater").count).to eq(1)
  end
end