# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SuturePriest do
  include_context "two player game"

  let!(:priest) { ResolvePermanent("Suture Priest", owner: p1) }

  it "gains you 1 life when another creature enters under your control" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.to change { p1.life }.by(1)
  end

  it "makes an opponent lose 1 life when a creature enters under their control" do
    expect { ResolvePermanent("Grizzly Bears", owner: p2) }.to change { p2.life }.by(-1)
  end

  it "doesn't change your life for an opponent's creature" do
    expect { ResolvePermanent("Grizzly Bears", owner: p2) }.not_to change { p1.life }
  end
end
