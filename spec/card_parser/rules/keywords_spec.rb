# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Keywords do
  it "parses a comma-separated keyword line" do
    expect(described_class.parse("Flying, first strike")).to eq(described_class.new(%i[flying first_strike]))
  end

  it "ignores lines that are not all keywords" do
    expect(described_class.parse("Flying, draws a card")).to be_nil
  end

  it "merges several lines into one DSL call" do
    merged = described_class.merge([described_class.new([:flying]), described_class.new([:haste])])
    expect(merged.flat_map(&:dsl_lines)).to eq(["keywords :flying, :haste"])
  end
end
