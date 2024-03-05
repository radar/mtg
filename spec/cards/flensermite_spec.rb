require "spec_helper"

RSpec.describe Magic::Cards::Flensermite do
  include_context "two player game"

  subject { ResolvePermanent("Flensermite") }

  it "has infect" do
    expect(subject.infect?).to eq(true)
  end
end
