# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::GraveyardReplacement do
  it "reads the shuffle-into-library replacement on the card itself" do
    rule = described_class.parse("If ~ would be put into a graveyard from anywhere, reveal ~ and shuffle it into its owner's library instead.")
    expect(rule.kind).to eq(:shuffle)
    expect(rule.body_source).to include("Effects::ShuffleIntoLibrary", "def replacement_effects = { Effects::MovePermanentZone",
                                        "def zone_replacement_effects = { Effects::MoveCardZone")
  end

  it "reads the exile-instead replacement for instants and sorceries" do
    rule = described_class.parse("If an instant or sorcery card would be put into a graveyard from anywhere, exile it instead.")
    expect(rule.kind).to eq(:exile)
    expect(rule.types).to eq(%w[Instant Sorcery])
    expect(rule.body_source).to include('any_type?("Instant", "Sorcery")', "Effects::ExileCard")
  end

  it "reads a single type" do
    expect(described_class.parse("If a creature card would be put into a graveyard from anywhere, exile it instead.").types).to eq(%w[Creature])
  end

  it "ignores other replacement wording" do
    expect(described_class.parse("If a card would be put into a graveyard from anywhere, exile it instead.")).to be_nil
    expect(described_class.parse("If ~ would die, exile it instead.")).to be_nil
  end
end
