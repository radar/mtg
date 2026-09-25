# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Count do
  it "counts your permanents with a named collection for card types" do
    expect(described_class.parse("Equipment you control")).to eq("controller.equipment.count")
    expect(described_class.parse("creature you control")).to eq("controller.creatures.count")
    expect(described_class.parse("artifact you control")).to eq("controller.artifacts.count")
  end

  it "counts other types with by_type" do
    expect(described_class.parse("Elf you control")).to eq('controller.permanents.by_type("Elf").count')
  end

  it "leaves out whatever `this` names for \"other\"" do
    expect(described_class.parse("other Elf you control")).to eq('controller.permanents.by_type("Elf").except(source).count')
    expect(described_class.parse("other creature you control", this: "actor")).to eq("controller.creatures.except(actor).count")
  end

  it "counts cards in your hand and graveyard" do
    expect(described_class.parse("card in your hand")).to eq("controller.hand.count")
    expect(described_class.parse("card in your graveyard")).to eq("controller.graveyard.cards.count")
    expect(described_class.parse("creature card in your graveyard")).to eq("controller.graveyard.creatures.count")
    expect(described_class.parse("Elf card in your graveyard")).to eq('controller.graveyard.by_type("Elf").count')
  end

  it "doesn't count what it doesn't know" do
    expect(described_class.parse("opponent you have")).to be_nil
    expect(described_class.parse("card in target player's graveyard")).to be_nil
  end
end
