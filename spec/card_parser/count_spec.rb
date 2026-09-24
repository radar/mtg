# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Count do
  it "counts permanents you control by type, optionally leaving out itself" do
    expect(described_class.parse("Equipment you control")).to eq('controller.permanents.count { _1.type?("Equipment") }')
    expect(described_class.parse("creature you control")).to eq('controller.permanents.count { _1.type?("Creature") }')
    expect(described_class.parse("other Elf you control")).to eq('(controller.permanents - [source]).count { _1.type?("Elf") }')
  end

  it "counts cards in your hand and graveyard" do
    expect(described_class.parse("card in your hand")).to eq("controller.hand.count")
    expect(described_class.parse("card in your graveyard")).to eq("controller.graveyard.cards.count")
    expect(described_class.parse("creature card in your graveyard")).to eq('controller.graveyard.cards.count { _1.type?("Creature") }')
  end

  it "doesn't count what it doesn't know" do
    expect(described_class.parse("opponent you have")).to be_nil
    expect(described_class.parse("card in target player's graveyard")).to be_nil
  end
end
