# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Anthem do
  it "parses buffs, keywords, or both, for all or other creatures you control" do
    expect(described_class.parse("Creatures you control get +1/+1.")).to eq(described_class.new(false, 1, 1, []))
    expect(described_class.parse("Other creatures you control get +1/+0 and have vigilance.")).to eq(described_class.new(true, 1, 0, [:vigilance]))
    expect(described_class.parse("Creatures you control have flying and haste.")).to eq(described_class.new(false, nil, nil, %i[flying haste]))
  end

  it "ignores other lines" do
    expect(described_class.parse("Creatures you control get +1/+1 until end of turn.")).to be_nil
    expect(described_class.parse("Creatures you control have ward 2.")).to be_nil
    expect(described_class.parse("Other Elves you control get +1/+1.")).to be_nil
  end

  it "splits a buff with keywords into two static abilities" do
    rules = described_class.merge([described_class.parse("Other creatures you control get +1/+1 and have trample.")])
    expect(rules.map(&:class_base_name)).to eq(%w[CreaturesYouControlBuff CreaturesYouControlKeywords])
    expect(rules.first.class_source("CreaturesYouControlBuff")).to eq(<<~RUBY)
      class CreaturesYouControlBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { source.controller.creatures - [source] }
      end
    RUBY
    expect(rules.last.class_source("CreaturesYouControlKeywords")).to include("keyword_grants Keywords::TRAMPLE")
  end
end
