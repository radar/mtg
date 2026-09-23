# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Enchant do
  it "parses what the aura can enchant" do
    expect(described_class.parse("Enchant creature")).to eq(described_class.new("Creature", false))
    expect(described_class.parse("Enchant land")).to eq(described_class.new("Land", false))
    expect(described_class.parse("Enchant creature you control")).to eq(described_class.new("Creature", true))
  end

  it "ignores other lines" do
    expect(described_class.parse("Enchanted creature gets +1/+1.")).to be_nil
  end

  it "renders the enchant restriction and target choices" do
    source = described_class.new("Land", false).body_source
    expect(source).to include('enchant "Land"', "battlefield.lands")
  end
end
