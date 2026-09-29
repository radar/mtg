# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DundoolinWeaver do
  include_context "two player game"

  let(:relic) { Card("Mind Stone", owner: p1) }

  before { p1.graveyard.add(relic) }

  it "returns a permanent card from your graveyard when you control three or more creatures" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
    ResolvePermanent("Dundoolin Weaver", owner: p1)

    expect(relic.zone).to be_hand
  end

  it "does nothing with fewer than three creatures" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Dundoolin Weaver", owner: p1)

    expect(game.choices).to be_empty
    expect(relic.zone).to be_graveyard
  end

  it "does not count an opponent's creatures" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p2) }
    ResolvePermanent("Dundoolin Weaver", owner: p1)

    expect(game.choices).to be_empty
  end

  it "cannot return an instant" do
    p1.graveyard.remove(relic)
    bolt = Card("Lightning Bolt", owner: p1)
    p1.graveyard.add(bolt)
    2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
    ResolvePermanent("Dundoolin Weaver", owner: p1)

    expect(game.choices).to be_empty
  end
end
