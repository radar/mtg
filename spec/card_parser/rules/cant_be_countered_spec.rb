# frozen_string_literal: true

require "spec_helper"
require_relative "../card_parser_helpers"

RSpec.describe Magic::CardParser::Rules::CantBeCountered do
  include CardParserHelpers

  it "parses \"this spell can't be countered\" into a DSL call" do
    expect(described_class.parse("~ can't be countered.").dsl_lines).to eq(["cant_be_countered"])
    expect(described_class.parse("~ can't be blocked.")).to be_nil
  end

  it "generates a spell that can't be countered" do
    source = generate("Parsed Surge {1}{R}\nInstant\nThis spell can't be countered.\nParsed Surge deals 2 damage to any target.\n")
    expect(source).to include("cost generic: 1, red: 1\n      cant_be_countered\n")
  end
end
