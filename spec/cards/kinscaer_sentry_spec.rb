# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KinscaerSentry do
  include_context "two player game"

  let!(:sentry) { ResolvePermanent("Kinscaer Sentry", owner: p1) }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
  end

  it "is a 2/2 Kithkin Soldier with first strike and lifelink" do
    expect([sentry.power, sentry.toughness]).to eq([2, 2])
    expect(sentry).to be_first_strike
    expect(sentry).to be_lifelink
  end

  context "when attacking with creature cards in hand" do
    let!(:bears) { Card("Grizzly Bears", owner: p1) } # mana value 2
    let!(:elves) { Card("Wood Elves", owner: p1) } # mana value 3
    let!(:angel) { Card("Baneslayer Angel", owner: p1) } # mana value 5

    before { [bears, elves, angel].each { p1.hand.add(_1) } }

    it "may put a creature card with mana value X or less onto the battlefield tapped and attacking, X the attackers" do
      attack_with(sentry) # X = 1: nothing in hand qualifies
      expect(game.choices.last).to be_a(described_class::AttackTrigger::MayChoice)
      game.resolve_choice!
      expect(game.choices).to be_empty
      expect(bears.zone).to be_hand
    end

    it "counts every attacking creature you control" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(sentry, other) # X = 2
      game.resolve_choice!
      # Only the mana value 2 card qualifies, so it is put in without asking.
      expect(bears.zone).to be_battlefield
      expect(elves.zone).to be_hand
      expect(angel.zone).to be_hand
    end

    it "puts it onto the battlefield tapped and attacking" do
      others = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }
      attack_with(sentry, *others) # X = 3
      game.resolve_choice!
      expect(game.choices.last.choices.to_a).to contain_exactly(bears, elves)
      game.resolve_choice!(target: elves)

      creature = p1.creatures.find { _1.card == elves }
      expect(elves.zone).to be_battlefield
      expect(creature).to be_tapped
      expect(current_turn.attacking?(creature)).to eq(true)
      expect(p1.hand.cards).not_to include(elves)
      expect(angel.zone).to be_hand
    end

    it "does nothing when declined" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(sentry, other)
      game.skip_choice!
      expect(bears.zone).to be_hand
    end
  end

  it "doesn't trigger when another creature attacks alone" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(other)
    expect(game.choices).to be_empty
  end
end
