# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::BeholdCost do
  it "parses a required behold, with an alternative mana payment" do
    rule = described_class.parse("As an additional cost to cast ~, behold a Dragon or pay {1}.")

    expect(rule).to eq(described_class.new(type: "Dragon", mana: { generic: 1 }, optional: false, flash: false))
    expect(rule.body_source).to include("def additional_costs")
    # Hash#inspect changed in Ruby 3.4 ({:generic=>1} became {generic: 1}).
    expect(rule.body_source).to match(/Costs::Behold\.new\(self, type: "Dragon", or_mana: \{(:generic=>|generic: )1\}\)/)
  end

  it "parses a required behold with no alternative" do
    rule = described_class.parse("As an additional cost to cast ~, behold a Dragon.")

    expect(rule.mana).to be_nil
    expect(rule.body_source).to include('Costs::Behold.new(self, type: "Dragon")')
  end

  it "parses an optional behold into the kicker plumbing" do
    rule = described_class.parse("As an additional cost to cast ~, you may behold a Dragon.")

    expect(rule.optional).to be(true)
    expect(rule.body_source).to include("def kicker_cost")
    expect(rule.body_source).to include('Costs::OptionalBehold.new(self, type: "Dragon")')
  end

  it "parses the conditional flash line" do
    rule = described_class.parse("You may cast ~ as though it had flash if you behold a Dragon as an additional cost to cast it.")

    expect(rule.flash).to be(true)
    expect(rule.body_source).to include('type: "Dragon", grants_flash: true')
  end

  it "ignores other lines, other costs and unknown types" do
    expect(described_class.parse("As an additional cost to cast ~, behold a Dragon and exile it.")).to be_nil
    expect(described_class.parse("As an additional cost to cast ~, discard a card.")).to be_nil
    expect(described_class.parse("As an additional cost to cast ~, behold a Wibble.")).to be_nil
  end
end
