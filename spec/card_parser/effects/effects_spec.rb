# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effect do
  let(:e) { Magic::CardParser::Effects }

  it "parses damage to various targets" do
    expect(described_class.parse("~ deals 3 damage to any target.")).to eq(e.const_get(:DealDamage).new(3, "any target"))
    expect(described_class.parse("~ deals two damage to target creature.")).to eq(e.const_get(:DealDamage).new(2, "target creature"))
    expect(described_class.parse("It deals 1 damage to target player.").target_choices).to eq("game.players")
  end

  it "does not parse damage to unsupported targets" do
    expect(described_class.parse("~ deals 3 damage to each opponent.")).to be_nil
  end

  it "parses drawing and life gain" do
    expect(described_class.parse("Draw three cards.")).to eq(e.const_get(:DrawCards).new(3))
    expect(described_class.parse("You draw a card.")).to eq(e.const_get(:DrawCards).new(1))
    expect(described_class.parse("You gain 4 life.")).to eq(e.const_get(:GainLife).new(4))
  end

  it "parses destroy and exile with who controls the target" do
    expect(described_class.parse("Destroy target artifact.").target_choices).to eq("battlefield.artifacts")
    expect(described_class.parse("Exile target creature.").target_choices).to eq("battlefield.creatures")
    expect(described_class.parse("Exile target enchantment an opponent controls.").target_choices)
      .to eq("battlefield.not_controlled_by(controller).enchantments")
    expect(described_class.parse("Exile target creature.").resolve_call).to eq("trigger_effect(:exile, target: target)")
  end

  it "parses scry as a choice" do
    scry = described_class.parse("Scry 2.")
    expect(scry).to eq(e.const_get(:Scry).new(2))
    expect(scry.choice_base).to eq("Magic::Choice::Scry")
    expect(scry.choice_args).to eq("amount: 2")
    expect(e.const_get(:DrawCards).new(1).choice_base).to be_nil
  end

  it "parses life loss" do
    expect(described_class.parse("Target player loses 2 life.").resolve_call).to eq("trigger_effect(:lose_life, target: target, life: 2)")
    expect(described_class.parse("Target opponent loses 2 life.").target_choices).to eq("game.opponents(controller)")
    each = described_class.parse("Each opponent loses 1 life.")
    expect(each.target_choices).to be_nil
    expect(each.resolve_call).to include("game.opponents(controller).each")
    expect(described_class.parse("You lose 3 life.").resolve_call).to eq("trigger_effect(:lose_life, target: controller, life: 3)")
  end

  it "parses discarding" do
    expect(described_class.parse("Discard a card.").resolve_call).to eq("game.add_choice(Magic::Choice::Discard.new(player: controller))")
    two = described_class.parse("Target player discards two cards.")
    expect(two.target_choices).to eq("game.players")
    expect(two.resolve_call).to eq("2.times { game.add_choice(Magic::Choice::Discard.new(player: target)) }")
    expect(described_class.parse("Each opponent discards a card.").resolve_call).to include("game.opponents(controller).each")
  end

  it "parses +1/+1 counters on a target or on each creature you control" do
    targeted = described_class.parse("Put a +1/+1 counter on target creature you control.")
    expect(targeted.target_choices).to eq("battlefield.controlled_by(controller).creatures")
    expect(targeted.resolve_call).to eq('trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)')
    each = described_class.parse("Put two +1/+1 counters on each creature you control.")
    expect(each.target_choices).to be_nil
    expect(each.resolve_call).to include("battlefield.controlled_by(controller).creatures.each", "amount: 2")
    expect(described_class.parse("Put a +1/+1 counter on target artifact.")).to be_nil
  end

  it "parses creature tokens and defines their class" do
    token = described_class.parse("Create two 1/1 green Elf Warrior creature tokens with haste.")
    expect(token).to eq(e.const_get(:CreateToken).new(2, 1, 1, [:green], "Elf Warrior", [:haste]))
    expect(token.resolve_call).to eq("trigger_effect(:create_token, token_class: ElfWarriorToken, amount: 2)")
    expect(token.definitions.first).to include('ElfWarriorToken = Token.create("Elf Warrior")', "power 1", "colors :green", "keywords :haste")
    expect(described_class.parse("Create a 2/2 white and blue Knight creature token.").colors).to eq(%i[white blue])
    expect(described_class.parse("Create a 1/1 colorless Thopter creature token with flying and first strike.").keywords).to eq(%i[flying first_strike])
  end

  it "does not parse tokens with unknown keywords or noncreature tokens" do
    expect(described_class.parse("Create a 1/1 white Spirit creature token with ward 2.")).to be_nil
    expect(described_class.parse("Create a Treasure token.")).to be_nil
  end

  it "has no targets for untargeted effects" do
    expect(e.const_get(:DrawCards).new(1).target_choices).to be_nil
  end
end
