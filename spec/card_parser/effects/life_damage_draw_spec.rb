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
      .to include("Keywords::DEATHTOUCH")
  end
end

RSpec.describe Magic::CardParser::Condition do
  it "reads 'you attacked this turn'" do
    expect(described_class.parse("you attacked this turn")).to include("Events::CreatureAttacked")
  end
end
