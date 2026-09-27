# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlockImpostor do
  include_context "two player game"

  it "is a 2/2 shapeshifter with changeling, flash and flying" do
    impostor = ResolvePermanent("Flock Impostor", owner: p1)

    expect(impostor.power).to eq(2)
    expect(impostor.toughness).to eq(2)
    expect(impostor.card.changeling?).to be(true)
    expect(impostor.card.flash?).to be(true)
    expect(impostor.flying?).to be(true)
  end

  it "returns up to one other target creature you control to its owner's hand when it enters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Flock Impostor", owner: p1)
    game.settle!

    game.resolve_choice!(target: bears)

    expect(bears.card.zone).to be_hand
  end

  it "cannot target itself or an opponent's creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    opponents_bears = ResolvePermanent("Grizzly Bears", owner: p2)
    impostor = ResolvePermanent("Flock Impostor", owner: p1)

    choice = game.choices.first
    expect(choice.choices).to contain_exactly(bears)
    expect(choice.choices).not_to include(impostor, opponents_bears)
  end
end
