# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::EntersTapped do
  it "parses both wordings" do
    expect(described_class.parse("~ enters tapped.")).to eq(described_class.new)
    expect(described_class.parse("~ enters the battlefield tapped.")).to eq(described_class.new)
  end

  it "ignores other lines" do
    expect(described_class.parse("When ~ enters, draw a card.")).to be_nil
    expect(described_class.parse("~ enters tapped unless you control two or more other lands.")).to be_nil
  end

  it "renders the enters_tapped macro" do
    expect(described_class.new.body_source).to eq("enters_tapped\n")
  end
end
