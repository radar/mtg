# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::TokenDoubler do
  it "parses the doubling wording" do
    line = "If an effect would create one or more tokens under your control, it creates twice that many of those tokens instead."
    expect(described_class.parse(line)).to eq(described_class.new)
  end

  it "ignores other lines" do
    expect(described_class.parse("If an effect would create one or more tokens under your control, it creates three times that many.")).to be_nil
    expect(described_class.parse("When ~ enters, create a 1/1 white Soldier creature token.")).to be_nil
  end

  it "renders a token-doubling replacement effect" do
    source = described_class.new.body_source
    expect(source).to include("class TokenDoubler < ReplacementEffect", "amount: effect.amount * 2",
                              "def replacement_effects = { Effects::CreateToken => TokenDoubler }")
  end
end
