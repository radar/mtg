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

  it "parses scry as a choice" do
    scry = described_class.parse("Scry 2.")
    expect(scry).to eq(e.const_get(:Scry).new(2))
    expect(scry.choice_base).to eq("Magic::Choice::Scry")
    expect(e.const_get(:DrawCards).new(1).choice_base).to be_nil
  end

  it "renders resolve calls" do
    expect(e.const_get(:DrawCards).new(2).resolve_call).to eq("trigger_effect(:draw_cards, number_to_draw: 2)")
    expect(e.const_get(:GainLife).new(4).resolve_call).to eq("trigger_effect(:gain_life, target: controller, life: 4)")
  end

  it "parses token creation" do
    token = described_class.parse("Create a 1/1 white Human Warrior creature token.")
    expect(token).to eq(e.const_get(:CreateToken).new(1, 1, 1, [:white], "Human Warrior", false, []))
    expect(token.resolve_call).to eq("trigger_effect(:create_token, token_class: HumanWarriorToken)")
    expect(token.definitions).to include('HumanWarriorToken = Token.create "Human Warrior" do', 'creature_type "Human Warrior"', "colors :white")

    thopters = described_class.parse("Create two 1/1 colorless Thopter artifact creature tokens with flying.")
    expect(thopters.resolve_call).to include("amount: 2")
    expect(thopters.definitions).to include('artifact_creature_type "Thopter"', "keywords :flying")
    expect(thopters.definitions).not_to include("colors")
  end

  it "does not parse tokens with unknown colors or keywords" do
    expect(described_class.parse("Create a 1/1 purple Elf creature token.")).to be_nil
    expect(described_class.parse("Create a 1/1 green Elf creature token with ward 2.")).to be_nil
  end

  it "parses copying tokens" do
    text = "Choose any number of artifact tokens and/or creature tokens you control with different names. " \
           "For each of them, create a token that's a copy of it."
    expect(described_class.parse(text).resolve_call).to eq("game.add_choice(Magic::Choice::CopyTokens.new(actor: self))")
  end

  it "has no targets for untargeted effects" do
    expect(e.const_get(:DrawCards).new(1).target_choices).to be_nil
  end
end
