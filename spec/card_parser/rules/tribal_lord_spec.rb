# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::TribalLord do
  it "parses the creature type, power and toughness" do
    expect(described_class.parse("Other Elves you control get +1/+1.")).to eq(described_class.new("Elf", 1, 1))
  end

  it "adapts to other creature types, including irregular plurals" do
    {
      "Goblins" => "Goblin", "Wolves" => "Wolf", "Dwarves" => "Dwarf", "Faeries" => "Faerie", "Zombies" => "Zombie"
    }.each do |plural, singular|
      expect(described_class.parse("Other #{plural} you control get +2/-1.")).to eq(described_class.new(singular, 2, -1))
    end
  end

  it "rejects unknown creature types" do
    expect { described_class.parse("Other Blorps you control get +1/+1.") }
      .to raise_error(Magic::CardParser::UnsupportedCard, /Blorps/)
  end

  it "ignores other lines" do
    expect(described_class.parse("{T}: Add {G}.")).to be_nil
  end

  it "renders a static ability class" do
    source = described_class.new("Elf", 1, 1).class_source("PowerAndToughnessModification")
    expect(source).to include("modify power: 1, toughness: 1", 'other_creatures "Elf"')
  end
end
