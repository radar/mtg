# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::TapForMana do
  it "parses coloured mana" do
    expect(described_class.parse("{T}: Add {G}{G}{G}.")).to eq(described_class.new({ green: 3 }))
  end

  it "parses colourless mana" do
    expect(described_class.parse("{T}: Add {C}.")).to eq(described_class.new({ colorless: 1 }))
  end

  it "ignores other lines" do
    expect(described_class.parse("Flying")).to be_nil
  end

  it "renders a mana ability class" do
    expect(described_class.new({ green: 3 }).class_source("ManaAbility")).to include("add_mana(green: 3)")
  end
end
