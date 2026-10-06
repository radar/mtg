# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SoulWarden do
  include_context "two player game"

  let!(:warden) { ResolvePermanent("Soul Warden", owner: p1) }

  it "gains you 1 life when another creature enters under your control" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.to change { p1.life }.by(1)
  end

  it "gains you 1 life when a creature enters under an opponent's control" do
    expect { ResolvePermanent("Grizzly Bears", owner: p2) }.to change { p1.life }.by(1)
  end

  it "doesn't gain its own controller life for itself entering" do
    expect(p1.life).to eq(20)
  end

  it "gains only its controller life, not the opponent's own Soul Warden's" do
    ResolvePermanent("Soul Warden", owner: p2)

    expect(p1.life).to eq(21)
    expect(p2.life).to eq(20)
  end
end
