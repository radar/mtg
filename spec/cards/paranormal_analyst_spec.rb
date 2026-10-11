# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ParanormalAnalyst do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:analyst) { ResolvePermanent("Paranormal Analyst", owner: p1) }

  def manifest_dread!(player = p1)
    Magic::Choice::ManifestDread.perform(actor: analyst, player: player)
    game.settle!
  end

  it "is a 1/3 Human Detective" do
    expect([analyst.power, analyst.toughness]).to eq([1, 3])
  end

  it "puts the card you put into your graveyard into your hand when you manifest dread" do
    kept, milled = p1.library.first(2)
    manifest_dread!
    game.resolve_choice!(target: kept)
    game.settle!

    expect(milled.zone).to be_hand
    expect(p1.permanents.find(&:face_down?).card).to eq(kept)
  end

  it "works with a single card left in the library, which has nothing to put into the graveyard" do
    p1.library.cards.to_a.dup.each { p1.library.remove(_1) }
    only = Card("Forest", owner: p1).tap { p1.library.add(_1) }
    manifest_dread!

    expect(p1.permanents.find(&:face_down?).card).to eq(only)
    expect(game.choices).to be_empty
  end

  it "ignores the opponent manifesting dread" do
    p2_cards = p2.library.first(2)
    manifest_dread!(p2)
    game.resolve_choice!(target: p2_cards.first)

    expect(p2_cards.last.zone).to be_graveyard
  end

  it "only takes the card put into the graveyard this way, not other cards in it" do
    old = Card("Island", owner: p1).tap { p1.graveyard.add(_1) }
    manifest_dread!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(old.zone).to be_graveyard
  end
end
