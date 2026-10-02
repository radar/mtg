# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser Gate lands" do
  include CardParserHelpers
  include_context "two player game"

  let(:text) { "Test Guildgate\nLand — Gate\nThis land enters tapped.\n{T}: Add {W} or {U}.\n" }

  it "generates a Land with the Gate subtype, entering tapped, with a two-colour mana ability" do
    expect(generate(text)).to include("class TestGuildgate < Land", "type T::Land, T::Lands::Gate", "enters_tapped", "choices :white, :blue")
  end

  it "generates a land that plays like a hand-written guildgate" do
    load_card(text)
    go_to_main_phase!
    p1.play_land(land: Card("Test Guildgate"))
    permanent = p1.permanents.by_name("Test Guildgate").first

    expect(permanent.types).to include(Magic::Types::Lands::Gate)
    expect(permanent).to be_tapped
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "still rejects other land subtypes" do
    expect { generate("Odd Land\nLand — Desert\n") }.to raise_error(Magic::CardParser::UnsupportedCard)
  end
end
