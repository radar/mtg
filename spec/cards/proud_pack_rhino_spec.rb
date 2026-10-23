# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ProudPackRhino do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:angel) { ResolvePermanent("Serra Angel", owner: p2) }

  def shield_counters(permanent) = permanent.counters.of_type(Magic::Counters::Shield).count

  def enter_rhino
    go_to_main_phase!
    p1.add_mana(white: 3)
    p1.cast(card: Card("Proud Pack-Rhino", owner: p1)) { |a| a.pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/3 Rhino" do
    rhino = ResolvePermanent("Proud Pack-Rhino", owner: p1)

    expect(rhino.power).to eq(3)
    expect(rhino.toughness).to eq(3)
  end

  context "shield mode" do
    before do
      enter_rhino
      game.resolve_choice!(mode: :shield)
      game.resolve_choice!(target: bears)
    end

    it "puts a shield counter on the target permanent" do
      expect(shield_counters(bears)).to eq(1)
    end

    it "prevents destruction once, removing the counter" do
      bears.destroy!
      game.settle!

      expect(p1.creatures).to include(bears)
      expect(shield_counters(bears)).to eq(0)

      bears.destroy!
      game.settle!

      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  context "damage from a spell" do
    it "is prevented once by a shield counter" do
      bears.add_counter("shield")
      p1.add_mana(red: 1)
      p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bears) }
      game.stack.resolve!
      game.settle!

      expect(p1.creatures).to include(bears)
      expect(bears.damage).to eq(0)
      expect(shield_counters(bears)).to eq(0)
    end
  end

  context "proliferate mode" do
    it "adds another counter to a permanent that has one" do
      bears.add_counter("+1/+1")
      game.settle!

      enter_rhino
      game.resolve_choice!(mode: :proliferate)
      game.resolve_choice!(chosen: [bears])
      game.settle!

      expect(bears.power).to eq(4)
    end
  end
end
