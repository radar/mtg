# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Changeling do
  it "parses the keyword line" do
    expect(described_class.parse("Changeling")).to eq(described_class.new)
  end

  it "ignores other lines" do
    expect(described_class.parse("Changeling Wayfinder")).to be_nil
    expect(described_class.parse("Flying")).to be_nil
  end

  it "lists the engine's Changeling static ability instead of a nested class" do
    rule = described_class.new
    expect([rule.hook, rule.class_reference]).to eq([:static_abilities, "Abilities::Static::Changeling"])
  end
end
