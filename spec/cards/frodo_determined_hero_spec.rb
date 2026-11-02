# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FrodoDeterminedHero do
  include_context "two player game"

  let!(:sting) { ResolvePermanent("Sting The Glinting Dagger", owner: p1) } # MV 2
  before { go_to_main_phase! }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary {1}{W} 2/2 Halfling Warrior" do
    frodo = ResolvePermanent("Frodo Determined Hero", owner: p1)

    expect(frodo.legendary?).to be true
    expect(frodo.card.mana_value).to eq(2)
    expect([frodo.power, frodo.toughness]).to eq([2, 2])
    expect(frodo.type?("Halfling")).to be true
    expect(frodo.type?("Warrior")).to be true
  end

  describe "when Frodo enters" do
    def enter_frodo
      p1.add_mana(white: 1, colorless: 1)
      p1.cast(card: Card("Frodo Determined Hero", owner: p1)) do |a|
        a.pay_mana(generic: { colorless: 1 }, white: 1)
      end
      game.stack.resolve!
      game.settle!
      p1.creatures.find { _1.name == "Frodo, Determined Hero" }
    end

    it "attaches an Equipment of mana value 2 or 3 you control when you accept" do
      frodo = enter_frodo
      expect(game.choices.first).to be_a(Magic::Cards::FrodoDeterminedHero::MayAttach)
      game.resolve_choice!

      expect(sting.attached_to).to eq(frodo)
      expect(game.choices).to be_empty
    end

    it "does nothing when declined" do
      enter_frodo
      game.skip_choice!

      expect(sting.attached_to).to be_nil
      expect(game.choices).to be_empty
    end

    it "offers no choice when no Equipment of mana value 2 or 3 is available" do
      sting.destroy!
      game.settle!
      enter_frodo

      expect(game.choices).to be_empty
    end

    it "does not offer Equipment with mana value 4 or more, or an opponent's Equipment" do
      sting.destroy!
      game.settle!
      ResolvePermanent("Sting The Glinting Dagger", owner: p2)
      enter_frodo

      expect(game.choices).to be_empty
    end

    it "offers only the qualifying Equipment when several are available" do
      glamdring = ResolvePermanent("Glamdring", owner: p1) # MV 2
      mithril = ResolvePermanent("Mithril Coat", owner: p1) # MV 3
      enter_frodo
      game.resolve_choice!

      expect(game.choices.first.choices).to contain_exactly(sting, glamdring, mithril)
    end
  end

  describe "whenever Frodo attacks" do
    let!(:frodo) { ResolvePermanent("Frodo Determined Hero", owner: p1) }

    before do
      game.skip_choice! while game.choices.any?
    end

    it "attaches an Equipment of mana value 2 or 3 you control when you accept" do
      attack_with(frodo)
      expect(game.choices.first).to be_a(Magic::Cards::FrodoDeterminedHero::MayAttach)
      game.resolve_choice!

      expect(sting.attached_to).to eq(frodo)
    end

    it "does nothing when declined" do
      attack_with(frodo)
      game.skip_choice!

      expect(sting.attached_to).to be_nil
    end

    it "does not trigger when another creature attacks" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(bears)

      expect(game.choices).to be_empty
      expect(sting.attached_to).to be_nil
    end
  end

  describe "during your turn, prevent all damage that would be dealt to Frodo" do
    let!(:frodo) { ResolvePermanent("Frodo Determined Hero", owner: p1) }

    before do
      game.skip_choice! while game.choices.any?
    end

    it "prevents damage on your turn" do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Shock", owner: p1)) do |a|
        a.pay_mana(red: 1)
        a.targeting(frodo)
      end
      game.stack.resolve!
      game.settle!

      expect(frodo.damage).to eq(0)
      expect(frodo.zone).to eq(game.battlefield)
    end

    it "does not prevent damage on the opponent's turn, and other creatures take damage on yours" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.add_mana(red: 1)
      p1.cast(card: Card("Shock", owner: p1)) do |a|
        a.pay_mana(red: 1)
        a.targeting(bears)
      end
      game.stack.resolve!
      game.settle!
      expect(bears.damage).to eq(2)

      go_to_main_phase_for!(p2)
      p2.add_mana(red: 1)
      p2.cast(card: Card("Shock", owner: p2)) do |a|
        a.pay_mana(red: 1)
        a.targeting(frodo)
      end
      game.stack.resolve!
      game.settle!

      expect(p1.graveyard.cards.map(&:name)).to include("Frodo, Determined Hero")
    end
  end
end
