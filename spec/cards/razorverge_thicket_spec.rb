require "spec_helper"

RSpec.describe Magic::Cards::RazorvergeThicket do
  include_context "two player game"

  it "enters untapped with two or fewer other lands" do
    land = ResolvePermanent("Razorverge Thicket", owner: p1)

    expect(land).to be_untapped
  end

  it "enters tapped with more than two other lands" do
    3.times { ResolvePermanent("Forest", owner: p1) }
    land = ResolvePermanent("Razorverge Thicket", owner: p1)

    expect(land).to be_tapped
  end
end