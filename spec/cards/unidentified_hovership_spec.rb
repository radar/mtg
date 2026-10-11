# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnidentifiedHovership do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:small) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:big) { ResolvePermanent("Baneslayer Angel", owner: p2).tap { _1.add_counter("+1/+1") } } # toughness 6
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def enter!
    hovership = ResolvePermanent("Unidentified Hovership", owner: p1)
    game.settle!
    hovership
  end

  it "is a 2/2 flying Vehicle with crew 1" do
    hovership = ResolvePermanent("Unidentified Hovership", owner: p1)
    game.settle!
    game.skip_choice! while game.choices.any?

    expect(hovership.types).to include("Vehicle")
    expect(hovership.card).to have_keyword(:flying)
    expect(hovership.card.class::CREW).to eq(1)
  end

  it "exiles up to one target creature with toughness 5 or less when it enters" do
    enter!
    expect(game.choices.last.choices).to contain_exactly(small, mine)
    game.resolve_choice!(target: small)

    expect(game.exile.cards).to include(small.card)
    expect(big.zone).to be_battlefield
  end

  it "may exile nothing" do
    enter!
    game.skip_choice!

    expect(game.exile.cards).to be_empty
  end

  it "has the exiled card's owner manifest dread when it leaves the battlefield" do
    hovership = enter!
    game.resolve_choice!(target: small)
    hovership.destroy!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::ManifestDread)
    expect(choice.player).to eq(p2)
    game.resolve_choice!(target: choice.choices.first)
    expect(p2.permanents.count(&:face_down?)).to eq(1)
  end

  it "does nothing when it leaves with nothing exiled" do
    hovership = enter!
    game.skip_choice!
    hovership.destroy!
    game.settle!

    expect(game.choices).to be_empty
  end
end
