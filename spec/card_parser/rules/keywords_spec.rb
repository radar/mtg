# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Keywords do
  it "parses a comma-separated keyword line" do
    expect(described_class.parse("Flying, first strike")).to eq(described_class.new(%i[flying first_strike]))
  end

  it "parses changeling" do
    expect(described_class.parse("Changeling")).to eq(described_class.new([:changeling]))
  end

  it "ignores lines that are not all keywords" do
    expect(described_class.parse("Flying, draws a card")).to be_nil
  end

  it "merges several lines into one DSL call" do
    merged = described_class.merge([described_class.new([:flying]), described_class.new([:haste])])
    expect(merged.flat_map(&:dsl_lines)).to eq(["keywords :flying, :haste"])
  end

  it "reads a keyword phrase with commas and and" do
    expect(described_class.phrase("flying")).to eq([:flying])
    expect(described_class.phrase("flying, first strike, and haste")).to eq(%i[flying first_strike haste])
    expect(described_class.phrase("flying and ward 2")).to be_nil
  end
end

RSpec.describe Magic::CardParser::Rules::Keywords, "keywords with values" do
  def dsl(line) = described_class.merge([described_class.parse(line)]).flat_map(&:dsl_lines)

  it "reads toxic and hexproof from a colour as keyword objects" do
    expect(dsl("Toxic 2")).to eq(["keywords Keywords::Toxic.new(2)"])
    expect(dsl("Reach, hexproof from blue")).to eq(["keywords :reach, Keywords::HexproofFrom.new(:blue)"])
  end

  it "reads ward with a mana cost or a life payment" do
    expect(dsl("Flying, ward {2}")).to eq(["keywords :flying", "ward generic: 2"])
    expect(dsl("Ward—Pay 3 life.")).to eq(["ward life: 3"])
  end

  it "reads protection from colours, multicolored and card types" do
    expect(dsl("Protection from red and from blue"))
      .to eq(["protections [Protection.from_color(:red), Protection.from_color(:blue)]"])
    expect(dsl("Protection from multicolored"))
      .to eq(["protections [Protection.new(condition: -> (card) { card.multi_colored? })]"])
    expect(dsl("Vigilance, protection from creatures"))
      .to eq(["keywords :vigilance", "protections [Protection.new(condition: -> (card) { card.type?(\"Creature\") })]"])
  end

  it "reads kicker, flashback and cycling costs" do
    expect(dsl("Kicker {1}{G}")).to eq(["kicker_cost generic: 1, green: 1"])
    expect(dsl("Flashback {3}{R}")).to eq(["flashback Costs::Mana.new(generic: 3, red: 1)"])
    expect(dsl("Cycling {2}")).to eq(["cycling generic: 2"])
  end

  it "rejects values it can't represent" do
    expect(described_class.parse("Ward—Discard a card.")).to be_nil
    expect(described_class.parse("Protection from everything")).to be_nil
    expect(described_class.parse("Kicker—Sacrifice a creature.")).to be_nil
  end

  it "rejects two of the same keyword with a value" do
    rules = [described_class.parse("Ward {1}"), described_class.parse("Ward {2}")]

    expect { described_class.merge(rules) }.to raise_error(Magic::CardParser::UnsupportedCard, /more than one ward/)
  end
end
