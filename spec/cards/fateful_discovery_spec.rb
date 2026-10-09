# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FatefulDiscovery do
  include_context "two player game"

  let!(:discovery) { ResolvePermanent("Fateful Discovery", owner: p1) }

  it "draws a card when an artifact you control enters" do
    expect { ResolvePermanent("Short Sword", owner: p1) }.to change { p1.hand.count }.by(1)
  end

  it "doesn't draw for an artifact an opponent controls" do
    expect { ResolvePermanent("Short Sword", owner: p2) }.not_to(change { p1.hand.count })
  end

  it "doesn't draw for a nonartifact permanent" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.not_to(change { p1.hand.count })
  end
end
