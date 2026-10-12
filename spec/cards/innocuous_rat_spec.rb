# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InnocuousRat do
  include_context "two player game"

  let!(:rat) { ResolvePermanent("Innocuous Rat", owner: p1) }

  it "is a 1/1 Rat" do
    expect([rat.power, rat.toughness]).to eq([1, 1])
  end

  it "manifests dread when it dies" do
    rat.destroy!
    game.settle!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.graveyard.cards.map(&:name)).to include("Innocuous Rat")
    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  it "does nothing while it lives" do
    expect(game.choices).to be_empty
    expect(p1.permanents.count(&:face_down?)).to eq(0)
  end
end
