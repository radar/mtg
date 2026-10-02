# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::YouthfulValkyrie do
  include_context "two player game"

  let!(:valkyrie) { ResolvePermanent("Youthful Valkyrie", owner: p1) }

  def counters = valkyrie.counters.of_type(Magic::Counters["+1/+1"]).count

  it "is a 1/3 flying Angel" do
    expect([valkyrie.power, valkyrie.toughness]).to eq([1, 3])
    expect(valkyrie).to be_flying
  end

  it "gets a +1/+1 counter when another Angel enters under your control" do
    ResolvePermanent("Serra Angel", owner: p1)

    expect(counters).to eq(1)
  end

  it "doesn't trigger for a non-Angel" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(counters).to eq(0)
  end

  it "doesn't trigger for an opponent's Angel" do
    ResolvePermanent("Serra Angel", owner: p2)

    expect(counters).to eq(0)
  end
end
