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

  it "parses surveil as a choice" do
    surveil = described_class.parse("Surveil 2.")
    expect(surveil).to eq(e.const_get(:Surveil).new(2))
    expect(surveil.choice_base).to eq("Magic::Choice::Surveil")
    expect(surveil.choice_args).to eq("amount: 2")
  end

  it "parses look at the top cards and take one to hand as a choice" do
    look = described_class.parse("Look at the top four cards of your library. You may reveal a Goblin, Swamp, or Mountain card from among them and put it into your hand. Put the rest on the bottom of your library in a random order.")
    expect(look).to eq(e.const_get(:LookAtTopCards).new(4, %w[Goblin Swamp Mountain]))
    expect(look.choice_base).to eq("Magic::Choice::LookAtTopCards")
    expect(look.choice_args).to eq(["amount: 4", "filter: ->(card) { card.any_type?(\"Goblin\", \"Swamp\", \"Mountain\") }"])
    expect(described_class.parse("Look at the top four cards of your library. You may reveal a Merfolk or Island card from among them and put it into your hand. Put the rest on the bottom of your library in a random order.").types).to eq(%w[Merfolk Island])
  end

  it "parses untapping a target, an earlier target or the enchanted creature" do
    expect(described_class.parse("Untap target land you control.").target_choices).to eq("battlefield.controlled_by(controller).lands")
    it = described_class.parse("Untap that creature.")
    expect([it.target_choices, it.earlier_target?, it.resolve_call]).to eq([nil, true, "target.untap!"])
    tap = described_class.parse("Tap enchanted creature.")
    expect([tap.target_choices, tap.earlier_target?]).to eq([nil, false])
    expect(tap.resolve_call).to eq("trigger_effect(:tap, target: #{Magic::CardParser::Effect::THIS}.attached_to)")
  end

  it "parses gaining control, for good or until end of turn" do
    threaten = described_class.parse("Gain control of target creature until end of turn.")
    expect([threaten.target_choices, threaten.resolve_call]).to eq(["battlefield.creatures", "target.gain_control_until_eot!(controller)"])
    expect(described_class.parse("Gain control of target artifact.").resolve_call).to eq("target.controller = controller")
  end

  it "parses an effect on an earlier target that only applies to one type" do
    goat = described_class.parse("If that creature is a Goat, it also gets +3/+0 until end of turn.")
    expect(goat.earlier_target?).to eq(true)
    expect(goat.target_choices).to be_nil
    expect(goat.resolve_call).to eq("if target.type?(\"Goat\")\n  trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 0)\nend")
    expect(described_class.parse("If that creature is a Goat, draw a card.")).to be_nil
  end

  it "parses fighting, with an optional target" do
    fight = described_class.parse("~ fights target creature you don't control.")
    expect([fight.target_choices, fight.optional_target?]).to eq(["battlefield.not_controlled_by(controller).creatures", false])
    expect(fight.resolve_call).to eq("#{Magic::CardParser::Effect::THIS}.fights!(target)")
    up_to = described_class.parse("Enchanted creature fights up to one target creature an opponent controls.")
    expect(up_to.optional_target?).to eq(true)
    expect(up_to.resolve_call).to eq("#{Magic::CardParser::Effect::THIS}.attached_to.fights!(target)")
    expect(described_class.parse("~ fights target artifact.")).to be_nil
  end

  it "parses exiling until ~ leaves the battlefield" do
    hold = described_class.parse("Exile up to one target nonland permanent an opponent controls until ~ leaves the battlefield.")
    expect(hold.target_choices).to eq("battlefield.not_controlled_by(controller).nonland")
    expect(hold.optional_target?).to eq(true)
    expect(hold.resolve_call).to eq("#{Magic::CardParser::Effect::THIS}.exile_until_leaves!(target)")
  end

  it "parses becoming a creature until end of turn" do
    core = described_class.parse("~ becomes a 4/4 artifact creature until end of turn.")
    expect(core.resolve_call).to eq("#{Magic::CardParser::Effect::THIS}.become_creature!(power: 4, toughness: 4, types: [T::Artifact])")
    land = described_class.parse("~ becomes a 3/3 Elemental creature with haste until end of turn. It's still a land.")
    expect(land.resolve_call).to include('types: [T::Creatures["Elemental"]]', "keyword: :haste")
    expect(described_class.parse("~ becomes a 2/2 blue creature until end of turn.")).to be_nil
  end

  it "parses changing colors until end of turn" do
    all = described_class.parse("Target creature you control becomes all colors until end of turn.")
    expect(all.target_choices).to eq("battlefield.controlled_by(controller).creatures")
    expect(all.resolve_call).to eq("target.change_colors!([:white, :blue, :black, :red, :green])")
    expect(described_class.parse("~ becomes red until end of turn.").resolve_call).to eq("#{Magic::CardParser::Effect::THIS}.change_colors!([:red])")
    expect(described_class.parse("It becomes colorless until end of turn.").earlier_target?).to eq(true)
  end

  it "parses surveil as a choice" do
    surveil = described_class.parse("Surveil 2.")
    expect(surveil).to eq(e.const_get(:Surveil).new(2))
    expect(surveil.choice_base).to eq("Magic::Choice::Surveil")
    expect(surveil.choice_args).to eq("amount: 2")
  end

  it "parses life loss" do
    expect(described_class.parse("Target player loses 2 life.").resolve_call).to eq("trigger_effect(:lose_life, target: target, life: 2)")
    expect(described_class.parse("Target opponent loses 2 life.").target_choices).to eq("game.opponents(controller)")
    each = described_class.parse("Each opponent loses 1 life.")
    expect(each.target_choices).to be_nil
    expect(each.resolve_call).to include("game.opponents(controller).each")
    expect(described_class.parse("You lose 3 life.").resolve_call).to eq("trigger_effect(:lose_life, target: controller, life: 3)")
  end

  it "parses mill" do
    expect(described_class.parse("Mill two cards.")).to eq(e.const_get(:Mill).new("you", 2))
    expect(described_class.parse("Mill two cards.").resolve_call).to eq("controller.mill(2)")
    expect(described_class.parse("Each opponent mills three cards.").resolve_call).to eq("game.opponents(controller).each { _1.mill(3) }")
    target = described_class.parse("Target player mills 4 cards.")
    expect(target.target_choices).to eq("game.players")
    expect(target.resolve_call).to eq("target.mill(4)")
  end

  it "parses mill then return a card from among them as a choice" do
    mill = described_class.parse("Mill four cards, then you may return a permanent card from among them to your hand.")
    expect(mill).to eq(e.const_get(:MillThenReturn).new(4, "permanent"))
    expect(mill.choice_base).to eq("Magic::Choice::ReturnFromAmong")
    expect(mill.choice_args).to eq(["cards: controller.mill(4)", "filter: ->(card) { card.permanent? }"])
    expect(described_class.parse("Mill three cards, then you may return a creature card from among them to your hand.").choice_args.last)
      .to eq('filter: ->(card) { card.type?("Creature") }')
  end

  it "parses discarding unless you discard a card of a type, as a choice" do
    discard = described_class.parse("Then discard two cards unless you discard a creature card.")
    expect(discard).to eq(e.const_get(:DiscardUnless).new(2, "Creature"))
    expect(discard.choice_base).to eq("Magic::Choice::DiscardUnless")
    expect(discard.choice_args).to eq(["amount: 2", 'card_type: "Creature"'])
  end

  it "parses exiling a creature instead if it would die this turn" do
    exile = described_class.parse("If that creature would die this turn, exile it instead.")
    expect(exile).to be_a(e.const_get(:ExileInsteadIfDies))
    expect(exile.resolve_call).to include("target.register_turn_replacement", "ExileInsteadOfDying")
  end

  it "parses countering a spell, optionally by type or mana value" do
    expect(described_class.parse("Counter target spell.").target_choices).to eq("game.stack.spells")
    expect(described_class.parse("Counter target spell with mana value 2.").target_choices)
      .to eq("game.stack.spells.select { _1.card.mana_value == 2 }")
    expect(described_class.parse("Counter target noncreature spell.").target_choices)
      .to eq('game.stack.spells.select { !_1.card.type?("Creature") }')
    expect(described_class.parse("Counter target creature spell.").resolve_call).to eq("trigger_effect(:counter_spell, target: target)")
  end

  it "parses an up-to-one target getting base power and toughness and all creature types until end of turn" do
    base = described_class.parse("Choose up to one other target creature. Until end of turn, that creature has base power and toughness 4/4 and gains all creature types.")
    expect(base).to eq(e.const_get(:BaseStatsUntilEndOfTurn).new(true, 4, 4, true))
    expect(base.optional_target?).to eq(true)
    expect(base.target_choices).to eq("(battlefield.creatures - [#{Magic::CardParser::Effect::THIS}])")
    expect(base.resolve_call).to include("target.modify_base_power(4)", "target.modify_base_toughness(4)", "target.add_types")
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
  end

  it "parses a token with changeling as a keyword, alone or with other keywords" do
    shapeshifter = described_class.parse("Create a 1/1 colorless Shapeshifter creature token with changeling.")
    expect(shapeshifter.changeling).to eq(true)
    expect(shapeshifter.keywords).to eq([])
    expect(shapeshifter.definitions).to include("keywords :changeling")
    expect(shapeshifter.definitions).not_to include("static_abilities")

    flyer = described_class.parse("Create a 1/1 colorless Shapeshifter creature token with flying and changeling.")
    expect(flyer.changeling).to eq(true)
    expect(flyer.definitions).to include("keywords :flying, :changeling")
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
    expect(before.resolve_call).to eq('trigger_effect(:modify_power_toughness, target: target, power: controller.permanents.by_type("Elf").count, ' \
                                      'toughness: controller.permanents.by_type("Elf").count)')
    other = described_class.parse("~ gets +2/+0 until end of turn for each other Goblin you control.")
    expect(other.resolve_call).to include("power: 2 * controller.permanents.by_type(\"Goblin\").except(#{this}).count", "toughness: 0")
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

  it "parses bouncing and tapping a target permanent" do
    bounce = described_class.parse("Return target nonland permanent an opponent controls to its owner's hand.")
    expect(bounce.target_choices).to eq("battlefield.not_controlled_by(controller).nonland")
    expect(bounce.resolve_call).to eq("trigger_effect(:return_to_owners_hand, target: target)")
    expect(described_class.parse("Return target creature to its owner's hand.").target_choices).to eq("battlefield.creatures")
    tap = described_class.parse("Tap target creature.")
    expect([tap.target_choices, tap.resolve_call]).to eq(["battlefield.creatures", "trigger_effect(:tap, target: target)"])
  end

  it "parses countering a spell on the stack, by type" do
    expect(described_class.parse("Counter target spell.").target_choices).to eq("game.stack.spells")
    expect(described_class.parse("Counter target creature spell.").target_choices).to eq('game.stack.spells.select { _1.card.type?("Creature") }')
    expect(described_class.parse("Counter target noncreature spell.").target_choices).to eq('game.stack.spells.select { !_1.card.type?("Creature") }')
    expect(described_class.parse("Counter target instant or sorcery spell.").target_choices)
      .to eq('game.stack.spells.select { _1.card.type?("Instant") || _1.card.type?("Sorcery") }')
    expect(described_class.parse("Counter target spell.").resolve_call).to eq("trigger_effect(:counter_spell, target: target)")
  end

  it "parses milling" do
    expect(described_class.parse("Target player mills three cards.").resolve_call).to eq("target.mill(3)")
    expect(described_class.parse("Target player mills three cards.").target_choices).to eq("game.players")
    expect(described_class.parse("Each opponent mills two cards.").resolve_call).to eq("game.opponents(controller).each { _1.mill(2) }")
    expect(described_class.parse("Mill four cards.").resolve_call).to eq("controller.mill(4)")
  end

  it "parses searching your library as a choice" do
    ramp = described_class.parse("Search your library for a basic land card, put it onto the battlefield tapped, then shuffle.")
    expect(ramp.choice_base).to eq("Magic::Choice::SearchLibrary")
    expect(ramp.choice_args).to eq(["to_zone: :battlefield", "enters_tapped: true", "upto: 1", "filter: Filter[:basic_lands]"])
    tutor = described_class.parse("Search your library for a creature card, reveal it, put it into your hand, then shuffle.")
    expect(tutor.choice_args).to eq(["to_zone: :hand", "enters_tapped: false", "upto: 1", "filter: Filter[:creatures]", "reveal: true"])
    expect(described_class.parse("Search your library for an artifact card, put it into your hand, then shuffle.")).to be_nil
  end

  it "parses Treasure, Food and Clue tokens" do
    expect(described_class.parse("Create a Treasure token.").resolve_call).to eq("trigger_effect(:create_token, token_class: Tokens::Treasure)")
    expect(described_class.parse("Create two Food tokens.").resolve_call).to eq("trigger_effect(:create_token, token_class: Tokens::Food, amount: 2)")
    expect(described_class.parse("Create a Clue token.").resolve_call).to include("Tokens::Clue")
    expect(described_class.parse("Create a Blood token.")).to be_nil
  end

  it "has no targets for untargeted effects" do
    expect(e.const_get(:DrawCards).new(1).target_choices).to be_nil
  end
end
