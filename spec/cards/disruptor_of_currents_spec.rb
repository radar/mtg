# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DisruptorOfCurrents do
  include_context "two player game"

  it "is a 3/3 merfolk wizard with flash and convoke" do
    disruptor = ResolvePermanent("Disruptor of Currents", owner: p1)

    expect(disruptor.card.types).to include("Merfolk", "Wizard")
    expect(disruptor.power).to eq(3)
    expect(disruptor.toughness).to eq(3)
    expect(disruptor.card.flash?).to be(true)
    expect(disruptor.card.convoke?).to be(true)
  end

  it "returns up to one other target nonland permanent to its owner's hand when it enters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Disruptor of Currents", owner: p1)
    game.settle!

    game.resolve_choice!(target: bears)

    expect(bears.card.zone).to be_hand
  end

  it "cannot target a land" do
    forest = ResolvePermanent("Forest", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Disruptor of Currents", owner: p1)

    choice = game.choices.first
    expect(choice.choices).to include(bears)
    expect(choice.choices).not_to include(forest)
  end
end
