# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effect do
  let(:e) { Magic::CardParser::Effects }

  it "parses reveal-the-hand-and-choose-a-discard, with and without an excluded type" do
    duress = described_class.parse("Target opponent reveals their hand. You choose a noncreature, nonland card from it. That player discards that card.")
    expect(duress).to eq(e.const_get(:RevealHandDiscard).new(%w[Creature Land]))
    expect(duress.target_choices).to eq("game.opponents(controller)")
    pilfer = described_class.parse("Target opponent reveals their hand. You choose a nonland card from it. That player discards that card.")
    expect(pilfer.excluded_types).to eq(%w[Land])
    any = described_class.parse("Target opponent reveals their hand. You choose a card from it. That player discards that card.")
    expect(any.excluded_types).to eq([])
  end

  it "parses 'each player' and 'that player' draws, life loss and damage" do
    expect(described_class.parse("Each player draws a card.").resolve_call)
      .to eq("game.players.each { trigger_effect(:draw_cards, player: _1) }")
    expect(described_class.parse("That player draws an additional card.").resolve_call)
      .to eq("[that_player].each { trigger_effect(:draw_cards, player: _1) }")
    expect(described_class.parse("That player loses 5 life.").resolve_call).to eq("trigger_effect(:lose_life, target: that_player, life: 5)")
    expect(described_class.parse("~ deals 2 damage to that player.").resolve_call).to include("[that_player]")
  end

  it "parses 'for each' draw and life gain amounts" do
    draw = Magic::CardParser::EffectList.parse("Draw a card for each different mana value among nonland permanents you control.")
    expect(draw.effects.first.amount).to eq("controller.permanents.reject(&:land?).map(&:mana_value).uniq.count")
    gain = Magic::CardParser::EffectList.parse("You gain 2 life for each attacking creature.")
    expect(gain.effects.first.amount).to eq("2 * event.attacks.count { _1.attacker.controller == controller }")
  end
end

RSpec.describe Magic::CardParser::Effect, "(batch 3)" do
  let(:e) { Magic::CardParser::Effects }

  it "parses discard-unless-a-condition" do
    effect = described_class.parse("Then discard a card unless you attacked this turn.")
    expect(effect).to be_a(e.const_get(:DiscardUnlessCondition))
    expect(effect.resolve_call).to start_with("unless game.current_turn.events.any?")
    expect(described_class.parse("Discard a card unless you have no cards in hand.")).to be_a(e.const_get(:DiscardUnlessCondition))
    expect(described_class.parse("Discard a card unless you flip a coin.")).to be_nil
  end

  it "parses damage if a player has exactly N life" do
    effect = described_class.parse("If target player has exactly 10 life, ~ deals 10 damage to that player.")
    expect(effect.target_choices).to eq("game.players")
    expect(effect.resolve_call).to eq("trigger_effect(:deal_damage, target: target, damage: 10) if target.life == 10")
  end

  it "parses a +1/+1 counter before a bite as one two-target effect" do
    bite = described_class.parse("Put a +1/+1 counter on target creature you control. Then that creature deals damage equal to its power to target creature an opponent controls.")
    expect(bite.counter).to be(true)
    expect(bite.resolve_call.lines.map(&:strip)).to eq(["biter, victim = targets", 'trigger_effect(:add_counter, counter_type: "+1/+1", target: biter, amount: 1)', "biter.bite!(victim)"])
    expect(described_class.parse("Target creature you control deals damage equal to its power to target creature.").counter).to be(false)
  end

  it "parses 'it deals damage equal to its power'" do
    effect = described_class.parse("It deals damage equal to its power to target creature or planeswalker.")
    expect(effect.target_choices).to eq("battlefield.creatures + battlefield.planeswalkers")
    expect(effect.resolve_call).to include("damage: #{Magic::CardParser::Effect::THIS}.power")
  end

  it "parses a wheel" do
    expect(described_class.parse("Each player discards their hand, then draws seven cards.").resolve_call)
      .to include("number_to_draw: 7").and include("discard!")
  end

  it "parses poison counters" do
    expect(described_class.parse("That player gets two poison counters.").resolve_call).to include("[that_player].each").and include("amount: 2")
    expect(described_class.parse("Target player gets a poison counter.").target_choices).to eq("game.players")
    expect(described_class.parse("You get a poison counter.").resolve_call).to include("[controller].each")
  end

  it "parses lose life unless they discard / sacrifice" do
    quandary = described_class.parse("That player loses 5 life unless they discard a card.")
    expect(quandary).to eq(e.const_get(:LoseLifeUnless).new("that player", 5, true, false))
    artist = described_class.parse("Each opponent loses 3 life unless that player sacrifices a nonland permanent of their choice or discards a card.")
    expect(artist).to eq(e.const_get(:LoseLifeUnless).new("each opponent", 3, true, true))
    expect(artist.resolve_call).to include("game.opponents(controller).each").and include("sacrifice: true")
  end
end

RSpec.describe Magic::CardParser::Rules::BlockingRestriction, "can't be blocked by a type" do
  it "parses it, with the blocker passed in" do
    expect(described_class.parse("~ can't be blocked by Humans.").body_source).to eq("def can_be_blocked?(blocker) = !blocker.type?(\"Human\")\n")
    expect(described_class.parse("~ can't be blocked by Elves.").body_source).to include('"Elf"')
    expect(described_class.parse("~ can't be blocked by Blorbs.")).to be_nil
  end
end

RSpec.describe Magic::CardParser::Rules::NoMaximumHandSize do
  it "parses it as a marker" do
    expect(described_class.parse("You have no maximum hand size.").body_source).to eq("def no_maximum_hand_size? = true\n")
  end
end

RSpec.describe Magic::CardParser::Rules::ActivatedAbility, "activation condition" do
  it "reads 'Activate only if <condition>.' into requirements_met?" do
    rule = described_class.parse("{1}, {T}, Sacrifice ~: Draw a card. Activate only if you control five or more lands.")
    expect(rule.only_if).to eq("controller.lands.count >= 5")
    expect(rule.class_source("Ability")).to include("def requirements_met?\n    controller.lands.count >= 5\n  end")
    expect(described_class.parse("{T}: Draw a card. Activate only if the moon is full.")).to be_nil
  end
end

RSpec.describe Magic::CardParser::Rules::Trigger, "(batch 3)" do
  def parse(line) = described_class.parse(line)

  it "reads 'that many' as the damage dealt, for damage triggers only" do
    expect(parse("Whenever ~ deals combat damage to a player, put that many incubation counters on it.").effect_list.effects.first.counters)
      .to eq([["event.damage", "incubation"]])
    expect(parse("Whenever a source you control deals noncombat damage to an opponent, you draw that many cards.").kind.name)
      .to eq("NoncombatDamageToOpponentTrigger")
    expect(parse("Whenever you attack, put that many +1/+1 counters on ~.")).to be_nil
  end

  it "reads 'that player controls' as 'an opponent controls' in a combat damage trigger" do
    effect = parse("Whenever ~ deals combat damage to a player, you may destroy target artifact or enchantment that player controls.").effect_list.effects.first
    expect(effect.effect.target_choices).to include("not_controlled_by(controller)")
  end

  it "reads 'it' as ~ in a combat damage trigger" do
    expect(parse("Whenever ~ deals combat damage to a player, put a +1/+1 counter on it.").effect_list.effects.first.who).to eq(:self)
  end
end

RSpec.describe Magic::CardParser::Rules::Trigger do
  def parse(line) = described_class.parse(line)

  it "reads the attacker triggers" do
    expect(parse("Whenever a white creature you control attacks, you gain 1 life.").condition)
      .to eq("event.attacker.controller == controller && event.attacker.colors.include?(:white)")
    expect(parse("Whenever a creature you control attacks, you gain 1 life.").condition).to eq("event.attacker.controller == controller")
    expect(parse("Whenever one or more creatures you control attack, you gain 1 life.").kind.name).to eq("CreaturesAttackTrigger")
  end

  it "reads draw triggers" do
    expect(parse("Whenever an opponent draws a card, that player loses 1 life.").condition).to eq("opponent?")
    expect(parse("Whenever you draw a card, you gain 1 life.").condition).to eq("you?")
    expect(parse("Whenever you draw your second card each turn, draw a card.").kind.name).to eq("SecondCardDrawTrigger")
    expect(parse("At the beginning of each player's draw step, that player draws an additional card.").kind.event).to eq("Events::DrawStep")
  end

  it "reads an opponent's coloured spell cast, with or without a type" do
    expect(parse("Whenever an opponent casts a white or blue instant or sorcery spell, ~ deals 2 damage to that player.").condition)
      .to eq('opponent? && (spell.colors.include?(:white) || spell.colors.include?(:blue)) && (spell.type?("Instant") || spell.type?("Sorcery"))')
    expect(parse("Whenever an opponent casts a spell, that player loses 1 life.").condition).to eq("opponent?")
  end

  it "reads counters put on ~ with a once-each-turn limit" do
    trigger = parse("Whenever you put one or more +1/+1 counters on ~, draw a card. This ability triggers only once each turn.")
    expect(trigger.kind.base).to eq("TriggeredAbility::OncePerTurn")
    expect(parse("Whenever you attack, draw a card. This ability triggers only once each turn.")).to be_nil
  end

  it "reads a keyword creature's combat damage to a player" do
    expect(parse("Whenever a creature you control with deathtouch deals combat damage to a player, you gain 1 life.").condition)
      .to include("event.source.deathtouch?")
  end
end

RSpec.describe Magic::CardParser::Condition do
  it "reads 'you attacked this turn'" do
    expect(described_class.parse("you attacked this turn")).to include("Events::CreatureAttacked")
  end

  it "reads 'it/~ has a <type> counter on it' as one or more" do
    expect(described_class.parse("it has a divinity counter on it")).to eq("source.counters.of_type(Counters::Divinity).count >= 1")
    expect(described_class.parse("~ has three or more time counters on it")).to eq("source.counters.of_type(Counters::Time).count >= 3")
  end
end

RSpec.describe Magic::CardParser::Rules::EntersWithCounters, "if cast from your hand" do
  it "marks the counter as conditional on being cast from the hand" do
    rule = described_class.parse("~ enters with a divinity counter on it if you cast it from your hand.")
    expect(rule.body_source).to eq("enters_with_counters \"divinity\", 1, if_cast_from_hand: true\n")
    expect(described_class.parse("~ enters with a divinity counter on it.").body_source).to eq("enters_with_counters \"divinity\", 1\n")
  end
end

RSpec.describe Magic::CardParser::Effect, "(discard hand)" do
  it "parses discarding a whole hand" do
    expect(described_class.parse("Each opponent discards their hand.").resolve_call)
      .to eq("game.opponents(controller).each { |player| [*player.hand.cards].each(&:discard!) }")
    expect(described_class.parse("Target opponent discards their hand.").target_choices).to eq("game.opponents(controller)")
    expect(described_class.parse("You discard your hand.").resolve_call).to start_with("[controller].each")
  end
end
