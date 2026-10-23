# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VolatileStormdrake do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_drake
    drake = Card("Volatile Stormdrake", owner: p1)
    p1.hand.add(drake)
    p1.cast(card: drake) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "has flying" do
    expect(ResolvePermanent("Volatile Stormdrake", owner: p1)).to be_flying
  end

  describe "enters" do
    let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p2) } # mana value 6
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) } # mana value 2

    before { p1.add_mana(blue: 2) }

    it "exchanges control with the chosen creature" do
      cast_drake
      game.resolve_choice!(target: bears)
      game.settle!

      expect(p2.creatures.map(&:name)).to include("Volatile Stormdrake")
      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "gives four energy and keeps a cheap creature when {E} is paid" do
      cast_drake
      game.resolve_choice!(target: bears)
      game.resolve_choice!
      game.settle!

      expect(p1.energy).to eq(2)
      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "sacrifices the creature when {E} is not paid" do
      cast_drake
      game.resolve_choice!(target: bears)
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(4)
      expect(p1.creatures.map(&:name)).not_to include("Grizzly Bears")
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "sacrifices the creature when it costs more {E} than you have" do
      cast_drake
      game.resolve_choice!(target: dreadmaw)
      game.settle!

      expect(p1.energy).to eq(4)
      expect(p1.creatures.map(&:name)).not_to include("Colossal Dreadmaw")
    end
  end

  describe "hexproof from abilities" do
    let!(:drake) { ResolvePermanent("Volatile Stormdrake", owner: p2) }

    it "cannot be targeted by an opponent's ability" do
      source = ResolvePermanent("Grizzly Bears", owner: p1)

      expect(drake.can_be_targeted_by?(source, controller: p1)).to be(false)
    end

    it "can be targeted by an opponent's spell" do
      shock = Card("Shock", owner: p1)

      expect(drake.can_be_targeted_by?(shock, controller: p1)).to be(true)
    end
  end
end
