# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::BlockingRestriction do
  it "parses can't block and can't be blocked" do
    expect(described_class.parse("~ can't block.").body_source).to eq("def can_block?(_) = false\n")
    expect(described_class.parse("~ can't be blocked.").body_source).to eq("def can_be_blocked?(_) = false\n")
  end

  it "ignores conditional or partial restrictions" do
    expect(described_class.parse("~ can't be blocked by creatures with power 2 or greater.")).to be_nil
    expect(described_class.parse("~ can't block alone.")).to be_nil
  end
end
