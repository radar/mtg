# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SyggWanderwineWisdom do
  include_context "two player game"
  before { go_to_main_phase! }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  describe "Sygg, Wanderwine Wisdom" do
    it "is a 2/2 legendary Merfolk Wizard that can't be blocked" do
      sygg = ResolvePermanent("Sygg, Wanderwine Wisdom", owner: p1)
      game.skip_choice!
      blocker = ResolvePermanent("Grizzly Bears", owner: p2)

      expect([sygg.power, sygg.toughness]).to eq([2, 2])
      expect(sygg).to be_legendary
      expect(sygg.can_be_blocked?(blocker)).to be(false)
    end

    it "lets a creature draw a card for combat damage to a player this turn when it enters" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Sygg, Wanderwine Wisdom", owner: p1)
      game.resolve_choice!(target: bears)
      hand = p1.hand.count
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      current_turn.attackers_declared!
      current_turn.combat_damage!
      game.settle!

      expect(p2.life).to eq(18)
      expect(p1.hand.count).to eq(hand + 1)
    end

    it "does not draw for a creature that wasn't chosen" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Sygg, Wanderwine Wisdom", owner: p1)
      game.resolve_choice!(target: other)
      hand = p1.hand.count
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      current_turn.attackers_declared!
      current_turn.combat_damage!
      game.settle!

      expect(p1.hand.count).to eq(hand)
    end

    it "may pay {W} at the beginning of your first main phase to transform" do
      sygg = ResolvePermanent("Sygg, Wanderwine Wisdom", owner: p1)
      game.skip_choice!
      p1.add_mana(white: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(sygg.transformed?).to be(true)
      expect(sygg.name).to eq("Sygg, Wanderbrine Shield")
      expect(sygg.colors).to eq([:white])
      expect(sygg.mana_value).to eq(2)
    end
  end

  describe "Sygg, Wanderbrine Shield" do
    let!(:sygg) do
      ResolvePermanent("Sygg, Wanderwine Wisdom", owner: p1).tap do |permanent|
        game.skip_choice!
        permanent.transform!
        game.settle!
      end
    end

    it "can't be blocked" do
      expect(sygg.can_be_blocked?(ResolvePermanent("Grizzly Bears", owner: p2))).to be(false)
    end

    it "gives a creature you control protection from each color until your next turn when it transforms into it" do
      # transforming into the back face asked for a target; sygg is the only creature, so it was chosen
      expect(sygg.protected_from?(Card("Lightning Bolt", owner: p2))).to be(true)
      expect(sygg.protected_from?(Card("Island", owner: p2))).to be(false) # colourless
    end

    it "lasts through the opponent's turn and ends when your next turn begins" do
      game.next_turn # the opponent's turn
      go_to_main_phase! # through their upkeep
      expect(sygg.protected_from?(Card("Lightning Bolt", owner: p2))).to be(true)

      game.next_turn # your turn: protection ends as it begins
      go_to_main_phase!
      expect(sygg.protected_from?(Card("Lightning Bolt", owner: p2))).to be(false)
    end

    it "may pay {U} to transform back" do
      p1.add_mana(blue: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)
      game.settle!

      expect(sygg.transformed?).to be(false)
      expect(sygg.name).to eq("Sygg, Wanderwine Wisdom")
    end
  end
end
