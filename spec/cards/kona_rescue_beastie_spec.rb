# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KonaRescueBeastie do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:kona) { ResolvePermanent("Kona, Rescue Beastie", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) } }
  let!(:bolt) { Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) } }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a legendary 4/3 Beast Survivor" do
    expect([kona.power, kona.toughness]).to eq([4, 3])
    expect(kona.card.types).to include("Beast", "Survivor")
    expect(kona.card).to be_legendary
  end

  it "lets you put a permanent card from hand onto the battlefield at second main if tapped" do
    kona.tap!
    to_second_main!
    game.resolve_choice!(targets: [bears])
    game.settle!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    expect(p1.hand.cards).not_to include(bears)
  end

  it "only offers permanent cards" do
    kona.tap!
    to_second_main!

    expect(game.choices.first.choices).to include(bears)
    expect(game.choices.first.choices).not_to include(bolt)
  end

  it "does nothing if you decline" do
    kona.tap!
    to_second_main!
    game.skip_choice!

    expect(p1.creatures.map(&:name)).not_to include("Grizzly Bears")
  end

  it "does nothing if untapped" do
    to_second_main!

    expect(game.choices).to be_empty
  end
end
