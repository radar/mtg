# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::ShuffleGraveyardIntoLibrary do
  it "reads 'Shuffle your graveyard into your library.'" do
    effect = Magic::CardParser::Effect.parse("Shuffle your graveyard into your library.")
    expect(effect).to be_a(described_class)
    expect(effect.resolve_call).to include("controller.graveyard.cards", "controller.shuffle!")
  end
end

RSpec.describe Magic::CardParser::Effects::SearchLibrary, "to the graveyard" do
  it "reads 'search your library for a card, put that card into your graveyard, then shuffle'" do
    effect = Magic::CardParser::Effect.parse("Search your library for a card, put that card into your graveyard, then shuffle.")
    expect(effect.to_zone).to eq(:graveyard)
    expect(effect.choice_args).to include("to_zone: :graveyard")
  end

  it "still reads the hand and battlefield forms" do
    expect(described_class.parse("Search your library for a creature card, reveal it, put it into your hand, then shuffle.").to_zone).to eq(:hand)
    expect(described_class.parse("Search your library for a basic land card, put it onto the battlefield tapped, then shuffle.").to_zone).to eq(:battlefield)
  end
end
