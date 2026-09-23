# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::CastDraw do
  it "parses the spell type" do
    expect(described_class.parse("Whenever you cast a creature spell, draw a card.")).to eq(described_class.new("Creature"))
  end

  it "adapts to other types, with an or a" do
    expect(described_class.parse("Whenever you cast an Elf spell, draw a card.")).to eq(described_class.new("Elf"))
    expect(described_class.parse("Whenever you cast an artifact spell, draw a card.")).to eq(described_class.new("Artifact"))
  end

  it "ignores other lines" do
    expect(described_class.parse("Whenever you cast a creature spell, scry 1.")).to be_nil
  end

  it "renders a spell-cast trigger" do
    source = described_class.new("Creature").class_source("SpellCastTrigger")
    expect(source).to include("TriggeredAbility::SpellCast", 'spell.type?("Creature") && you?', "trigger_effect(:draw_cards)")
  end
end
