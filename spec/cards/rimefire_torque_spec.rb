# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RimefireTorque do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:torque) do
    ResolvePermanent("Rimefire Torque", owner: p1).tap { game.resolve_choice!(creature_type: "Elf") }
  end

  def charge = torque.counters.of_type(Magic::Counters.named("charge")).count

  it "remembers the chosen creature type" do
    expect(torque.chosen_creature_type).to eq("Elf")
  end

  it "gets a charge counter whenever a permanent you control of the chosen type enters" do
    ResolvePermanent("Skyway Sniper", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Skyway Sniper", owner: p2)

    expect(charge).to eq(1)
  end

  describe "{T}, remove three charge counters" do
    before { 3.times { torque.add_counter(Magic::Counters.named("charge")) } }

    def activate
      p1.activate_ability(ability: torque.activated_abilities.first)
      game.stack.resolve!
    end

    def cast_bolt_at(target)
      bolt = Card("Lightning Bolt", owner: p1)
      p1.hand.add(bolt)
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(target) }
      game.settle!
    end

    it "copies the next instant or sorcery you cast this turn" do
      activate
      cast_bolt_at(p2)
      game.skip_choice! # keep the target
      game.stack.resolve!

      expect(charge).to eq(0)
      expect(p2.life).to eq(14)
    end

    it "lets the copy choose a new target" do
      victim = ResolvePermanent("Courser Of Kruphix", owner: p2)
      activate
      cast_bolt_at(p2)
      game.resolve_choice!
      game.resolve_choice!(target: victim)
      game.stack.resolve!

      expect(p2.life).to eq(17)
      expect(victim.damage).to eq(3)
    end

    it "copies only the next spell" do
      activate
      cast_bolt_at(p2)
      game.skip_choice!
      game.stack.resolve!
      torque.untap!
      cast_bolt_at(p2)
      game.stack.resolve!

      expect(p2.life).to eq(11) # bolt + copy, then a plain bolt
    end

    it "doesn't copy creature spells" do
      activate
      card = Card("Grizzly Bears", owner: p1)
      p1.hand.add(card)
      p1.add_mana(green: 2)
      p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      game.settle!

      expect(game.choices).to be_empty
    end

    it "needs three charge counters" do
      torque.remove_counter(counter_type: Magic::Counters.named("charge"), amount: 1)

      expect { p1.activate_ability(ability: torque.activated_abilities.first) }.to raise_error(StandardError)
    end
  end
end
