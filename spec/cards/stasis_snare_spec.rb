# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StasisSnare do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_rival) { ResolvePermanent("Bear Cub", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  let!(:snare) { ResolvePermanent("Stasis Snare", owner: p1) }

  it "has flash" do
    expect(snare.card.has_keyword?(:flash)).to eq(true)
  end

  it "exiles target creature an opponent controls until it leaves the battlefield" do
    game.resolve_choice!(target: rival)

    expect(game.exile.cards).to include(rival.card)
  end

  it "can't target your own creatures" do
    expect(game.choices.last.choices).not_to include(mine)
  end

  it "returns the creature when the enchantment leaves the battlefield" do
    game.resolve_choice!(target: rival)
    snare.destroy!
    game.settle!

    expect(game.exile.cards).not_to include(rival.card)
    expect(p2.creatures.map(&:name)).to include("Grizzly Bears")
  end
end
