# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpinerockTyrant do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:tyrant) { ResolvePermanent("Spinerock Tyrant", owner: p1) }

  it "is a 6/6 flying wither Dragon" do
    expect([tyrant.power, tyrant.toughness]).to eq([6, 6])
    expect(tyrant).to be_flying
    expect(tyrant).to be_wither
  end

  it "deals combat damage to creatures as -1/-1 counters" do
    blocker = ResolvePermanent("Courser Of Kruphix", owner: p2)
    tyrant.trigger_effect(:deal_combat_damage, source: tyrant, target: blocker, damage: 6)

    expect(blocker.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(6)
    expect(blocker.damage).to eq(0)
  end

  it "still deals ordinary damage to players" do
    tyrant.trigger_effect(:deal_combat_damage, source: tyrant, target: p2, damage: 6)

    expect(p2.life).to eq(14)
  end

  describe "when you cast an instant or sorcery with a single target" do
    let(:bolt) { Card("Lightning Bolt", owner: p1) }

    def cast_bolt_at(target)
      p1.hand.add(bolt)
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(target) }
      game.settle!
    end

    it "may copy it; accepting, the spells gain wither and the copy may have new targets" do
      victim = ResolvePermanent("Courser Of Kruphix", owner: p2)
      cast_bolt_at(victim)
      game.resolve_choice! # copy it
      game.skip_choice! # keep the original target for the copy
      game.stack.resolve!

      expect(victim.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(6) # 3 + 3, as counters
      expect(victim.damage).to eq(0)
    end

    it "lets the copy choose a new target" do
      victim = ResolvePermanent("Courser Of Kruphix", owner: p2)
      cast_bolt_at(victim)
      game.resolve_choice! # copy it
      game.resolve_choice! # choose new targets
      game.resolve_choice!(target: p2)
      game.stack.resolve!

      expect(p2.life).to eq(17)
      expect(victim.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(3)
    end

    it "declining copies nothing and the original deals ordinary damage" do
      cast_bolt_at(p2)
      game.skip_choice!
      game.stack.resolve!

      expect(p2.life).to eq(17)
    end

    it "doesn't trigger for a creature spell" do
      card = Card("Grizzly Bears", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 2)
      p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      game.settle!

      expect(game.choices).to be_empty
    end

    it "doesn't trigger for the opponent's spells" do
      go_to_main_phase_for!(p2)
      card = Card("Lightning Bolt", owner: p2)
      p2.hand.add(card)
      p2.add_mana(red: 1)
      p2.cast(card:) { _1.pay_mana(red: 1).targeting(p1) }
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
