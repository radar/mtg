# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlamewakePhoenix do
  include_context "two player game"

  let(:phoenix_card) { Card("Flamewake Phoenix", owner: p1) }

  it "is a 2/2 flying, haste Phoenix" do
    phoenix = ResolvePermanent("Flamewake Phoenix", owner: p1)

    expect([phoenix.power, phoenix.toughness]).to eq([2, 2])
    expect(phoenix.has_keyword?(:flying)).to eq(true)
    expect(phoenix.has_keyword?(:haste)).to eq(true)
  end

  describe "attacks each combat if able" do
    let!(:phoenix) { ResolvePermanent("Flamewake Phoenix", owner: p1) }

    before do
      go_to_main_phase!
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
    end

    it "must be declared as an attacker" do
      expect { current_turn.attackers_declared! }.to raise_error(Magic::Game::CombatPhase::IllegalAttack, /attacks each combat/)
    end

    it "can attack" do
      current_turn.declare_attacker(phoenix, target: p2)

      expect { current_turn.attackers_declared! }.not_to raise_error
    end

    it "doesn't have to attack while tapped" do
      phoenix.tap!

      expect { current_turn.attackers_declared! }.not_to raise_error
    end
  end

  describe "returning from your graveyard" do
    before do
      go_to_main_phase!
      p1.graveyard.add(phoenix_card)
    end

    def begin_combat!
      current_turn.beginning_of_combat!
      game.settle!
    end

    context "with a creature with power 4 or greater" do
      before { ResolvePermanent("Gate Colossus", owner: p1) }

      it "returns to the battlefield if you pay {R}" do
        p1.add_mana(red: 1)
        begin_combat!
        game.resolve_choice!

        expect(p1.creatures.map(&:card)).to include(phoenix_card)
      end

      it "stays in the graveyard if you decline" do
        p1.add_mana(red: 1)
        begin_combat!
        game.skip_choice!

        expect(phoenix_card.zone).to be_graveyard
      end

      it "offers nothing if you can't pay {R}" do
        begin_combat!

        expect(game.choices).to be_empty
        expect(phoenix_card.zone).to be_graveyard
      end

      it "doesn't trigger on the opponent's beginning of combat" do
        go_to_main_phase_for!(p2)
        p1.add_mana(red: 1)
        current_turn.beginning_of_combat!
        game.settle!

        expect(game.choices).to be_empty
        expect(phoenix_card.zone).to be_graveyard
      end
    end

    it "does nothing without a creature with power 4 or greater" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      p1.add_mana(red: 1)
      begin_combat!

      expect(game.choices).to be_empty
      expect(phoenix_card.zone).to be_graveyard
    end

    it "doesn't count an opponent's big creature" do
      ResolvePermanent("Gate Colossus", owner: p2)
      p1.add_mana(red: 1)
      begin_combat!

      expect(game.choices).to be_empty
    end
  end
end
