require "spec_helper"

RSpec.describe Magic::Cards::TheBindingOfTheTitans do
  include_context "two player game"

  it "enters with a lore counter" do
    saga = ResolvePermanent("The Binding Of The Titans", owner: p1)

    expect(saga.counters.of_type(Magic::Counters::Lore).count).to eq(1)
  end

  it "does not trigger a chapter when a lore counter goes on a different Saga" do
    saga = ResolvePermanent("The Binding Of The Titans", owner: p1)
    expect(p1.graveyard.count).to eq(3)

    ResolvePermanent("The Binding Of The Titans", owner: p2)

    expect(saga.counters.of_type(Magic::Counters::Lore).count).to eq(1)
    expect(p1.graveyard.count).to eq(6)
  end
end