# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StormplainDetainment do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:land) { ResolvePermanent("Forest", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  # Bears is the only legal target other than... the opponent's Forest is a land, so
  # the engine targets the sole nonland permanent automatically.
  let!(:detainment) { ResolvePermanent("Stormplain Detainment", owner: p1) }

  it "exiles the opponent's nonland permanent" do
    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
    expect(game.battlefield.creatures).not_to include(bears)
  end

  it "leaves lands and its controller's permanents alone" do
    expect(game.battlefield.to_a).to include(land, mine)
  end

  it "returns the exiled permanent when it leaves the battlefield" do
    detainment.destroy!
    game.settle!

    expect(game.exile.cards.map(&:name)).not_to include("Grizzly Bears")
    expect(p2.creatures.map(&:name)).to include("Grizzly Bears")
  end
end
