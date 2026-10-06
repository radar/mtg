# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SolemnSimulacrum do
  include_context "two player game"

  before { p1.library.add(Card("Forest", owner: p1)) }

  it "may fetch a basic land onto the battlefield tapped" do
    ResolvePermanent("Solemn Simulacrum", owner: p1)
    expect(game.choices.last).to be_a(described_class::MaySearchChoice)

    game.resolve_choice!
    forest = game.choices.last.choices.find { _1.name == "Forest" }
    game.resolve_choice!(targets: [forest])

    expect(game.battlefield.by_card(forest).first).to be_tapped
  end

  it "declines to search" do
    ResolvePermanent("Solemn Simulacrum", owner: p1)
    lands = p1.lands.count
    game.skip_choice!

    expect(p1.lands.count).to eq(lands)
  end

  it "draws a card when it dies" do
    solemn = ResolvePermanent("Solemn Simulacrum", owner: p1)
    game.skip_choice!

    expect do
      solemn.destroy!
      game.settle!
    end.to change { p1.hand.count }.by(1)
  end
end
