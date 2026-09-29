# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrubStoriedMatriarch do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:goblin_card) { Card("Boneclub Berserker", owner: p1) }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  describe "Grub, Storied Matriarch" do
    it "is a 2/1 menace legendary Goblin Warlock with a back face" do
      grub = ResolvePermanent("Grub, Storied Matriarch", owner: p1)

      expect([grub.power, grub.toughness]).to eq([2, 1])
      expect(grub).to be_menace
      expect(grub).to be_legendary
      expect(grub.card).to be_double_faced
    end

    it "returns up to one Goblin card from your graveyard to your hand when it enters" do
      p1.graveyard.add(goblin_card)
      ResolvePermanent("Grub, Storied Matriarch", owner: p1)
      game.resolve_choice!(target: goblin_card)

      expect(goblin_card.zone).to be_hand
    end

    it "may return nothing" do
      p1.graveyard.add(goblin_card)
      ResolvePermanent("Grub, Storied Matriarch", owner: p1)
      game.skip_choice!

      expect(goblin_card.zone).to be_graveyard
    end

    it "offers no choice without a Goblin card in the graveyard" do
      p1.graveyard.add(Card("Grizzly Bears", owner: p1))
      ResolvePermanent("Grub, Storied Matriarch", owner: p1)

      expect(game.choices).to be_empty
    end

    it "may pay {R} at the beginning of your first main phase to transform" do
      grub = ResolvePermanent("Grub, Storied Matriarch", owner: p1)
      p1.add_mana(red: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(grub.transformed?).to be(true)
      expect(grub.name).to eq("Grub, Notorious Auntie")
      expect(grub.colors).to eq([:red])
      expect(grub.mana_value).to eq(3)
      expect(grub).to be_menace
    end
  end

  describe "Grub, Notorious Auntie" do
    let!(:grub) do
      ResolvePermanent("Grub, Storied Matriarch", owner: p1).tap do |permanent|
        permanent.transform!
        game.settle!
      end
    end

    def attack_with(creature)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(creature, target: p2)
      game.notify!(Magic::Events::CreatureAttacked.new(attacker: creature, target: p2))
      game.settle!
    end

    it "returns a Goblin card again when it transforms back into the front face" do
      p1.graveyard.add(goblin_card)
      grub.transform!
      game.settle!

      expect(game.choices.last).to be_a(Magic::Cards::GrubStoriedMatriarch::ReturnChoice)
    end

    it "may blight 1 when it attacks; if it does, makes a tapped and attacking copy of the blighted creature" do
      bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
      attack_with(grub)
      game.resolve_choice! # the may choice
      game.resolve_choice!(target: bears)

      expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
      copy = p1.creatures.find { _1.token? && _1.name == "Courser of Kruphix" }
      expect(copy).not_to be_nil
      expect(copy).to be_tapped
      expect(current_turn.attacking?(copy)).to be(true)
      expect(copy.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)
    end

    it "sacrifices the token at the beginning of the end step" do
      bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
      attack_with(grub)
      game.resolve_choice!
      game.resolve_choice!(target: bears)
      copy = p1.creatures.find(&:token?)
      current_turn.end!
      game.settle!

      expect(p1.creatures).not_to include(copy)
    end

    it "does nothing if you decline to blight" do
      ResolvePermanent("Courser Of Kruphix", owner: p1)
      attack_with(grub)
      game.skip_choice!

      expect(p1.creatures.count(&:token?)).to eq(0)
    end

    it "may pay {B} to transform back" do
      p1.add_mana(black: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(grub.transformed?).to be(false)
      expect(grub.name).to eq("Grub, Storied Matriarch")
    end
  end
end
