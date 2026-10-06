# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SuturePriest do
  include_context "two player game"

  let!(:priest) { ResolvePermanent("Suture Priest", owner: p1) }

  it "may gain you 1 life when another creature enters under your control" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect { game.resolve_choice! }.to change { p1.life }.by(1)
  end

  it "does nothing when you decline the life gain" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect { game.skip_choice! }.not_to change { p1.life }
  end

  it "may make an opponent lose 1 life when a creature enters under their control" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect { game.resolve_choice! }.to change { p2.life }.by(-1)
  end

  it "does nothing when you decline to drain the opponent" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect { game.skip_choice! }.not_to change { p2.life }
  end

  it "doesn't change your life for an opponent's creature" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect { game.resolve_choice! }.not_to change { p1.life }
  end
end
