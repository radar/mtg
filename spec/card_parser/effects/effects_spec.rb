# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effect do
  let(:e) { Magic::CardParser::Effects }

  it "parses damage to various targets" do
    expect(described_class.parse("~ deals 3 damage to any target.")).to eq(e.const_get(:DealDamage).new(3, "any target"))
    expect(described_class.parse("~ deals two damage to target creature.")).to eq(e.const_get(:DealDamage).new(2, "target creature"))
    expect(described_class.parse("~ deals 1 damage to target player.").target_choices).to eq("game.players")
  end

  it "does not parse damage to unsupported targets" do
    expect(described_class.parse("~ deals 3 damage to each opponent.")).to be_nil
  end

  it "parses drawing, life gain and destruction" do
    expect(described_class.parse("Draw three cards.")).to eq(e.const_get(:DrawCards).new(3))
    expect(described_class.parse("You draw a card.")).to eq(e.const_get(:DrawCards).new(1))
    expect(described_class.parse("You gain 4 life.")).to eq(e.const_get(:GainLife).new(4))
    expect(described_class.parse("Destroy target artifact.").target_choices).to eq("battlefield.artifacts")
  end

  it "renders resolve calls" do
    expect(e.const_get(:DrawCards).new(2).resolve_call).to eq("trigger_effect(:draw_cards, number_to_draw: 2)")
    expect(e.const_get(:GainLife).new(4).resolve_call).to eq("trigger_effect(:gain_life, target: controller, life: 4)")
  end

  it "has no targets for untargeted effects" do
    expect(e.const_get(:DrawCards).new(1).target_choices).to be_nil
  end
end
