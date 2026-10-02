# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MischievousPup do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:cub) { ResolvePermanent("Bear Cub", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 3/1 Dog with flash" do
    pup = ResolvePermanent("Mischievous Pup", owner: p1)

    expect([pup.power, pup.toughness]).to eq([3, 1])
    expect(pup.card.has_keyword?(:flash)).to eq(true)
  end

  it "returns up to one other permanent you control to its owner's hand" do
    ResolvePermanent("Mischievous Pup", owner: p1)
    game.resolve_choice!(target: bears)

    expect(bears.card.zone).to be_hand
    expect(cub.zone).to be_battlefield
  end

  it "can't return an opponent's permanent or itself" do
    pup = ResolvePermanent("Mischievous Pup", owner: p1)

    expect(game.choices.last.choices).not_to include(rival)
    expect(game.choices.last.choices).not_to include(pup)
  end
end
