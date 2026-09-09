require "spec_helper"

RSpec.describe Magic::Cards::BalothPrime do
  include_context "two player game"

  it "enters with six stun counters" do
    baloth = ResolvePermanent("Baloth Prime", owner: p1)

    expect(baloth.counters.of_type(Magic::Counters::Stun).count).to eq(6)
  end

  it "removes a stun counter instead of untapping" do
    baloth = ResolvePermanent("Baloth Prime", owner: p1)
    expect(baloth.counters.of_type(Magic::Counters::Stun).count).to eq(6)
    baloth.untap_during_untap_step

    expect(baloth.counters.of_type(Magic::Counters::Stun).count).to eq(5)
    expect(baloth).to be_tapped
  end
end