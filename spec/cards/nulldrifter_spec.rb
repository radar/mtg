# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Nulldrifter do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Nulldrifter", owner: p1) }

  def attack(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a 4/4 flying Eldrazi Elemental" do
    drifter = ResolvePermanent("Nulldrifter", owner: p1)

    expect([drifter.power, drifter.toughness]).to eq([4, 4])
    expect(drifter).to have_keyword(:flying)
    expect(drifter.type?("Elemental")).to eq(true)
  end

  it "draws two cards when cast" do
    p1.hand.add(card)
    p1.add_mana(colorless: 7)
    hand = p1.hand.count

    p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 7 }) }
    game.settle!

    expect(p1.hand.count).to eq(hand - 1 + 2)
  end

  it "has annihilator 1" do
    drifter = ResolvePermanent("Nulldrifter", owner: p1)
    2.times { ResolvePermanent("Grizzly Bears", owner: p2) }

    attack(drifter)
    game.skip_choice!
    game.settle!

    expect(p2.permanents.size).to eq(1)
  end

  context "evoked for {2}{U}" do
    before do
      p1.hand.add(card)
      p1.add_mana(blue: 3)
    end

    it "draws two cards and is sacrificed when it enters" do
      hand = p1.hand.count
      p1.cast_as(:evoked, card: card) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
      game.settle!
      game.stack.resolve!
      game.settle!

      expect(p1.hand.count).to eq(hand - 1 + 2)
      expect(p1.creatures).to be_empty
      expect(p1.graveyard.cards).to include(card)
    end
  end

  it "stays on the battlefield when cast for its mana cost" do
    p1.hand.add(card)
    p1.add_mana(colorless: 7)
    p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 7 }) }
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(p1.creatures.map(&:name)).to eq(["Nulldrifter"])
  end
end
