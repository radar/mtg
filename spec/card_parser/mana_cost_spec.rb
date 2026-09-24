# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::ManaCost do
  it "parses generic and coloured symbols" do
    expect(described_class.parse("{2}{U}{U}")).to eq(generic: 2, blue: 2)
  end

  it "parses hybrid symbols into the engine's colour-sorted keys" do
    expect(described_class.parse("{B/G}{B/G}")).to eq(black_or_green: 2)
    expect(described_class.parse("{G/B}")).to eq(black_or_green: 1)
    expect(described_class.parse("{1}{R/W}{R/W}")).to eq(generic: 1, red_or_white: 2)
  end

  it "parses {X}" do
    expect(described_class.parse("{X}{R}")).to eq(x: 1, red: 1)
  end

  it "rejects symbols it doesn't understand" do
    expect { described_class.parse("{2/W}") }.to raise_error(Magic::CardParser::UnsupportedCard, /unsupported mana symbol/)
    expect { described_class.parse("{B/P}") }.to raise_error(Magic::CardParser::UnsupportedCard)
  end
end
