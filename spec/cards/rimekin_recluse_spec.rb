# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RimekinRecluse do
  include_context "two player game"

  it "is a 3/2 elemental wizard" do
    recluse = ResolvePermanent("Rimekin Recluse", owner: p1)

    expect(recluse.card.types).to include("Elemental", "Wizard")
    expect(recluse.power).to eq(3)
    expect(recluse.toughness).to eq(2)
  end

  it "returns up to one other target creature (any player's) to its owner's hand when it enters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Rimekin Recluse", owner: p1)
    game.settle!

    game.resolve_choice!(target: bears)

    expect(bears.card.zone).to be_hand
  end

  it "may decline (up to one)" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Rimekin Recluse", owner: p1)
    game.settle!

    game.skip_choice!

    expect(game.choices).to be_empty
  end
end
