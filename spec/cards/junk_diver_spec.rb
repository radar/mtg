# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JunkDiver do
  include_context "two player game"

  let!(:diver) { ResolvePermanent("Junk Diver", owner: p1) }

  def bury(name, player: p1)
    card = Card(name, owner: player)
    player.graveyard.add(card)
    card
  end

  it "is a 1/1 flying artifact creature" do
    expect(diver.power).to eq(1)
    expect(diver.toughness).to eq(1)
    expect(diver.flying?).to eq(true)
    expect(diver.type?("Artifact")).to eq(true)
  end

  it "returns another artifact card from your graveyard to your hand when it dies" do
    medallion = bury("Ruby Medallion")
    other = bury("Jet Medallion")
    bear = bury("Grizzly Bears")
    diver.destroy!
    game.settle!
    expect(game.choices.last.choices).to contain_exactly(medallion, other)
    expect(game.choices.last.choices).not_to include(bear)
    game.resolve_choice!(target: medallion)
    expect(medallion.zone).to eq(p1.hand)
    expect(p1.graveyard.cards).to include(diver.card)
  end

  it "cannot return an artifact from an opponent's graveyard" do
    theirs = bury("Ruby Medallion", player: p2)
    mine = bury("Jet Medallion")
    mine2 = bury("Pearl Medallion")
    diver.destroy!
    game.settle!
    expect(game.choices.last.choices).to contain_exactly(mine, mine2)
    expect(game.choices.last.choices).not_to include(theirs)
  end

  it "does nothing without another artifact card in the graveyard" do
    diver.destroy!
    game.settle!
    expect(game.choices).to be_empty
    expect(p1.graveyard.cards.map(&:name)).to eq(["Junk Diver"])
  end
end
