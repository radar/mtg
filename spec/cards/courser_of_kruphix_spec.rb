require "spec_helper"

RSpec.describe Magic::Cards::CourserOfKruphix do
  include_context "two player game"

  it "gains life when a land enters under your control" do
    ResolvePermanent("Courser of Kruphix", owner: p1)
    ResolvePermanent("Forest", owner: p1)

    expect(p1.life).to eq(21)
  end
end