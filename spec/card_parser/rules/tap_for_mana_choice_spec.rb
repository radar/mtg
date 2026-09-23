# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::TapForManaChoice do
  it "parses two colours" do
    expect(described_class.parse("{T}: Add {W} or {U}.")).to eq(described_class.new(%i[white blue]))
  end

  it "parses three colours" do
    expect(described_class.parse("{T}: Add {R}, {G}, or {W}.")).to eq(described_class.new(%i[red green white]))
  end

  it "parses any colour" do
    expect(described_class.parse("{T}: Add one mana of any color.")).to eq(described_class.new([:all]))
  end

  it "ignores single-mana and other lines" do
    expect(described_class.parse("{T}: Add {G}.")).to be_nil
    expect(described_class.parse("{T}: Add {G}{G}.")).to be_nil
    expect(described_class.parse("{T}: Add two mana of any one color.")).to be_nil
  end

  it "renders a mana ability with colour choices" do
    source = described_class.new(%i[green blue]).class_source("ManaAbility")
    expect(source).to eq("class ManaAbility < Magic::TapManaAbility\n  choices :green, :blue\nend\n")
  end
end
