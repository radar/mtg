# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Equip do
  it "parses the equip cost" do
    expect(described_class.parse("Equip {2}{R}")).to eq(described_class.new({ generic: 2, red: 1 }))
  end

  it "ignores other lines" do
    expect(described_class.parse("Equipped creature gets +1/+1.")).to be_nil
  end

  it "renders an equip DSL line" do
    expect(described_class.new({ generic: 1 }).dsl_lines).to eq(["equip [Costs::Mana.new(generic: 1)]"])
  end
end
