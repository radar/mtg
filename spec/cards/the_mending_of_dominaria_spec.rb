require "spec_helper"

RSpec.describe Magic::Cards::TheMendingOfDominaria do
  include_context "two player game"

  it "enters with a lore counter" do
    saga = ResolvePermanent("The Mending of Dominaria", owner: p1)

    expect(saga.counters.of_type(Magic::Counters::Lore).count).to eq(1)
  end
end