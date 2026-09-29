# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::SelfCostReduction do
  it "parses a per-count reduction" do
    rule = described_class.parse("~ costs {1} less to cast for each color among permanents you control.")

    expect([rule.amount, rule.count]).to eq([1, "controller.colors_among_permanents"])
    expect(rule.body_source).to include("{ generic: -> { -controller.colors_among_permanents } }", "controller = self.controller || owner")
  end

  it "parses a conditional reduction" do
    rule = described_class.parse("~ costs {2} less to cast if you control a Kithkin.")

    expect(rule.body_source).to include('-> { (controller.permanents.by_type("Kithkin").any?) ? -2 : 0 }')
  end

  it "ignores other lines and unknown conditions" do
    expect(described_class.parse("Creature spells you cast cost {1} less to cast.")).to be_nil
    expect(described_class.parse("~ costs {1} less to cast if the moon is full.")).to be_nil
  end
end
