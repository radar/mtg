# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::TapForManaPerPermanent do
  it "parses a permanent kind" do
    expect(described_class.parse("{T}: Add {G} for each creature you control.")).to eq(described_class.new(:green, "creatures"))
    expect(described_class.parse("{T}: Add {R} for each land you control.")).to eq(described_class.new(:red, "lands"))
  end

  it "parses a creature type, singular or plural" do
    expect(described_class.parse("{T}: Add {G} for each Elf you control.")).to eq(described_class.new(:green, "Elf"))
    expect(described_class.parse("{T}: Add {G} for each Elves you control.")).to eq(described_class.new(:green, "Elf"))
  end

  it "ignores other lines" do
    expect(described_class.parse("{T}: Add {G}{G}.")).to be_nil
  end

  it "renders the count expression" do
    expect(described_class.new(:green, "creatures").class_source("ManaAbility")).to include("add_mana(green: source.controller.creatures.count)")
    expect(described_class.new(:green, "Elf").class_source("ManaAbility")).to include('creatures.by_type("Elf").count')
  end
end
