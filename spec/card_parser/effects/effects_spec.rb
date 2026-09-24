# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effect do
  let(:e) { Magic::CardParser::Effects }

  it "parses damage to various targets" do
    expect(described_class.parse("~ deals 3 damage to any target.")).to eq(e.const_get(:DealDamage).new(3, "any target"))
    expect(described_class.parse("~ deals two damage to target creature.")).to eq(e.const_get(:DealDamage).new(2, "target creature"))
    expect(described_class.parse("It deals 1 damage to target player.").target_choices).to eq("game.players")
  end

  it "parses damage to each opponent, untargeted" do
    each = described_class.parse("~ deals 1 damage to each opponent.")
    expect(each.target_choices).to be_nil
    expect(each.resolve_call).to eq("game.opponents(controller).each { trigger_effect(:deal_damage, target: _1, damage: 1) }")
  end

  it "does not parse damage to unsupported targets" do
    expect(described_class.parse("~ deals 3 damage to each creature.")).to be_nil
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

  it "parses two-colour tokens and several keywords" do
    expect(described_class.parse("Create a 2/2 white and blue Knight creature token.").colors).to eq(%i[white blue])
    expect(described_class.parse("Create a 1/1 colorless Thopter creature token with flying and first strike.").keywords).to eq(%i[flying first_strike])
    expect(described_class.parse("Create a Treasure token.")).to be_nil
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
    expect(described_class.parse(text).resolve_call).to eq("game.add_choice(Magic::Choice::CopyTokens.new(actor: #{Magic::CardParser::Effect::THIS}))")
  end

  it "parses pumps of itself, a target and creatures you control" do
    this = Magic::CardParser::Effect::THIS
    own = described_class.parse("~ gets +1/+0 until end of turn.")
    expect([own.target_choices, own.resolve_call]).to eq([nil, "trigger_effect(:modify_power_toughness, target: #{this}, power: 1, toughness: 0)"])
    shrink = described_class.parse("Target creature an opponent controls gets -2/-2 until end of turn.")
    expect(shrink.target_choices).to eq("battlefield.not_controlled_by(controller).creatures")
    expect(shrink.resolve_call).to eq("trigger_effect(:modify_power_toughness, target: target, power: -2, toughness: -2)")
    expect(described_class.parse("Creatures you control get +1/+1 until end of turn.").resolve_call)
      .to start_with("battlefield.controlled_by(controller).creatures.each")
    expect(described_class.parse("Other creatures you control get +1/+1 until end of turn.").resolve_call)
      .to start_with("(battlefield.controlled_by(controller).creatures - [#{this}]).each")
    expect(described_class.parse("Target artifact gets +1/+1 until end of turn.")).to be_nil
    expect(described_class.parse("~ gets +1/+1.")).to be_nil
  end

  it "parses keyword grants until end of turn, alone or with a pump" do
    this = Magic::CardParser::Effect::THIS
    expect(described_class.parse("~ gains flying until end of turn.").resolve_call)
      .to eq("trigger_effect(:grant_keyword, target: #{this}, keyword: :flying)")
    both = described_class.parse("Target creature gets +2/+0 and gains first strike and trample until end of turn.")
    expect(both.target_choices).to eq("battlefield.creatures")
    expect(both.resolve_call).to eq(<<~RUBY.chomp)
      trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 0)
      trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
      trigger_effect(:grant_keyword, target: target, keyword: :trample)
    RUBY
    expect(described_class.parse("Creatures you control gain haste until end of turn.").resolve_call)
      .to eq("battlefield.controlled_by(controller).creatures.each { |creature| trigger_effect(:grant_keyword, target: creature, keyword: :haste) }")
    expect(described_class.parse("~ gains protection from red until end of turn.")).to be_nil
  end

  it "parses pumps that count, with the count before or after \"until end of turn\"" do
    this = Magic::CardParser::Effect::THIS
    before = described_class.parse("Target creature gets +1/+1 for each Elf you control until end of turn.")
    after = described_class.parse("Target creature gets +1/+1 until end of turn for each Elf you control.")
    expect(before).to eq(after)
    expect(before.resolve_call).to eq('trigger_effect(:modify_power_toughness, target: target, power: controller.permanents.count { _1.type?("Elf") }, ' \
                                      'toughness: controller.permanents.count { _1.type?("Elf") })')
    other = described_class.parse("~ gets +2/+0 until end of turn for each other Goblin you control.")
    expect(other.resolve_call).to include("power: 2 * (controller.permanents - [#{this}]).count", "toughness: 0")
    expect(described_class.parse("~ gains flying until end of turn for each Elf you control.")).to be_nil
    expect(described_class.parse("~ gets +1/+1 until end of turn for each opponent you have.")).to be_nil
  end

  it "parses returning a card from your graveyard" do
    creature = described_class.parse("Return target creature card from your graveyard to your hand.")
    expect(creature.target_choices).to eq('controller.graveyard.cards.select { _1.type?("Creature") }')
    expect(creature.resolve_call).to eq("target.move_to_hand!")
    expect(described_class.parse("Return target card from your graveyard to your hand.").target_choices).to eq("controller.graveyard.cards.to_a")
  end

  it "parses removing counters from itself and sacrificing itself" do
    this = Magic::CardParser::Effect::THIS
    expect(described_class.parse("Remove a time counter from ~.").resolve_call).to eq(
      "trigger_effect(:remove_counter, counter_type: Counters::Time, target: #{this}, amount: 1) " \
      "if #{this}.counters.of_type(Counters::Time).count >= 1"
    )
    expect(described_class.parse("Remove a widget counter from ~.")).to be_nil
    expect(described_class.parse("Sacrifice ~.").resolve_call).to eq("trigger_effect(:sacrifice, target: #{this})")
    expect(described_class.parse("sacrifice it.".capitalize)).to eq(e.const_get(:SacrificeSelf).new)
  end

  it "puts counters on ~ itself, untargeted" do
    own = described_class.parse("Put a +1/+1 counter on ~.")
    expect(own.target_choices).to be_nil
    expect(own.resolve_call).to eq("trigger_effect(:add_counter, counter_type: \"+1/+1\", target: #{Magic::CardParser::Effect::THIS}, amount: 1)")
  end

  it "targets another permanent, leaving itself out" do
    expect(described_class.parse("Destroy another target creature.").target_choices)
      .to eq("(battlefield.creatures - [#{Magic::CardParser::Effect::THIS}])")
  end

  it "parses flickering a target back under its owner's control" do
    flicker = described_class.parse("Exile another target creature you control, then return that card to the battlefield under its owner's control.")
    expect(flicker.target_choices).to eq("(battlefield.controlled_by(controller).creatures - [#{Magic::CardParser::Effect::THIS}])")
    expect(flicker.resolve_call).to include("trigger_effect(:exile, target: target)", "Permanent.resolve(", "cast: false")
    expect(described_class.parse("Exile target creature, then return it to the battlefield under your control.")).to be_nil
  end

  it "parses a library search onto the battlefield as a choice" do
    basic = described_class.parse("Search your library for a basic land card, put it onto the battlefield tapped, then shuffle.")
    expect(basic).to eq(e.const_get(:SearchLibrary).new("basic land", 1, true))
    expect(basic.choice_base).to eq("Magic::Choice::SearchLibrary")
    expect(basic.choice_args).to eq(["to_zone: :battlefield", "enters_tapped: true", "upto: 1", "filter: Filter[:basic_lands]"])

    forests = described_class.parse("Search your library for up to two Forest cards, put them onto the battlefield, then shuffle.")
    expect(forests.choice_args).to eq(["to_zone: :battlefield", "enters_tapped: false", "upto: 2", "filter: ->(card) { card.any_type?(\"Forest\") }"])
    expect(described_class.parse("Search your library for two basic land cards, put them onto the battlefield, then shuffle.")).to be_nil
  end

  it "targets nonland permanents" do
    expect(described_class.parse("Destroy target nonland permanent an opponent controls.").target_choices)
      .to eq("battlefield.not_controlled_by(controller).nonland")
  end

  it "parses putting a creature or planeswalker card from a graveyard onto the battlefield under your control" do
    reanimate = described_class.parse("Put target creature or planeswalker card from a graveyard onto the battlefield under your control.")
    expect(reanimate).to eq(e.const_get(:Reanimate).new(%w[Creature Planeswalker], true))
    expect(reanimate.target_choices).to eq('game.graveyard_cards.by_any_type("Creature", "Planeswalker")')
    expect(reanimate.resolve_call).to eq("trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)")
    expect(described_class.parse("Put target creature card from your graveyard onto the battlefield under your control.").target_choices)
      .to eq('controller.graveyard.cards.by_any_type("Creature")')
  end

  it "parses each opponent sacrificing a permanent of a type" do
    sacrifice = described_class.parse("Each opponent sacrifices a creature or planeswalker of their choice.")
    expect(sacrifice).to eq(e.const_get(:EachOpponentSacrifices).new(%w[Creature Planeswalker]))
    expect(sacrifice.target_choices).to be_nil
    expect(sacrifice.definitions).to include("class SacrificeChoice < Magic::Choice::Targeted", 'by_any_type("Creature", "Planeswalker")')
    expect(described_class.parse("Each opponent sacrifices an artifact.").permanent_types).to eq(%w[Artifact])
  end

  it "parses blight, for you, each opponent or a target opponent" do
    mine = described_class.parse("Blight 2.")
    expect(mine).to eq(e.const_get(:Blight).new("you", 2))
    expect(mine.choice_base).to eq("Magic::Choice::Blight")
    expect(mine.choice_guard).to eq("Magic::Choice::Blight.possible?(controller, game)")

    each = described_class.parse("Each opponent blights 1.")
    expect([each.choice_base, each.target_choices]).to eq([nil, nil])
    expect(each.resolve_call).to include("game.opponents(controller).each do |opponent|", "player: opponent")

    target = described_class.parse("Target opponent blights 2.")
    expect(target.target_choices).to eq("game.opponents(controller)")
    expect(target.resolve_call).to include("[target].each do |opponent|")
  end

  it "targets creatures of a type, attacking ones and others" do
    expect(described_class.parse("Target Elf you control gets +2/+2 until end of turn.").target_choices)
      .to eq('battlefield.controlled_by(controller).creatures.by_any_type("Elf")')
    expect(described_class.parse("Target attacking Goblin you control gets +1/+0 until end of turn.").target_choices)
      .to eq('battlefield.controlled_by(controller).creatures.by_any_type("Goblin").attacking')
    expect(described_class.parse("Another target Merfolk you control gets +2/+0 until end of turn.").target_choices)
      .to eq("(battlefield.controlled_by(controller).creatures.by_any_type(\"Merfolk\") - [#{Magic::CardParser::Effect::THIS}])")
    expect(described_class.parse("Destroy target Elf.").target_choices).to eq('battlefield.creatures.by_any_type("Elf")')
    expect(described_class.parse("Target Widget you control gets +2/+2 until end of turn.")).to be_nil
  end

  it "parses untapping" do
    expect(described_class.parse("Untap target Merfolk you control.").target_choices)
      .to eq('battlefield.controlled_by(controller).creatures.by_any_type("Merfolk")')
    expect(described_class.parse("Untap target creature.").resolve_call).to eq("target.untap!")
    expect(described_class.parse("Untap ~.").resolve_call).to eq("#{Magic::CardParser::Effect::THIS}.untap!")
    each = described_class.parse("Untap each other Merfolk you control.")
    expect(each.target_choices).to be_nil
    expect(each.resolve_call).to include('by_any_type("Merfolk")', "- [#{Magic::CardParser::Effect::THIS}]", ".each(&:untap!)")
  end

  it "has no targets for untargeted effects" do
    expect(e.const_get(:DrawCards).new(1).target_choices).to be_nil
  end
end
