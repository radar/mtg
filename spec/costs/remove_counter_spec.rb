# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Costs::RemoveCounter do
  include_context "two player game"

  let(:permanent) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "can be paid only while the source has enough counters of the type" do
    cost = described_class.new(permanent, Magic::Counters::Charge, amount: 2)
    expect(cost.can_pay?).to be(false)

    permanent.add_counter(Magic::Counters::Charge, amount: 2)
    expect(cost.can_pay?).to be(true)
  end
end
