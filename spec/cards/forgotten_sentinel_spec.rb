require "spec_helper"

RSpec.describe Magic::Cards::ForgottenSentinel do
  include_context "two player game"

  it "enters tapped" do
    permanent = ResolvePermanent("Forgotten Sentinel")
    expect(permanent).to be_tapped
  end
end
