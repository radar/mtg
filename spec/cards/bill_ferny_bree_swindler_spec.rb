# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BillFernyBreeSwindler do
  include_context "two player game"

  let!(:bill) { ResolvePermanent("Bill Ferny, Bree Swindler", owner: p1) }
  let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:second_blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  def attack!(attacker = bill)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
  end

  def block!(*blockers, attacker: bill)
    blockers.each { current_turn.declare_blocker(_1, attacker: attacker) }
    game.settle!
  end

  it "is a legendary 2/1" do
    expect([bill.power, bill.toughness]).to eq([2, 1])
    expect(bill).to be_legendary
  end

  describe "mode one" do
    it "creates a Treasure when blocked" do
      attack!
      block!(blocker)
      game.resolve_choice!(mode: described_class::ModeChoice::TREASURE)
      game.settle!

      expect(treasures.count).to eq(1)
    end

    it "triggers once however many creatures block it" do
      attack!
      block!(blocker, second_blocker)
      game.resolve_choice!(mode: described_class::ModeChoice::TREASURE)
      game.settle!

      expect(treasures.count).to eq(1)
      expect(game.choices).to be_empty
    end

    it "does not offer the Horse mode without a Horse" do
      attack!
      block!(blocker)

      expect(game.choices.last.choices).to eq([described_class::ModeChoice::TREASURE])
      expect { game.resolve_choice!(mode: described_class::ModeChoice::HORSE) }.to raise_error(ArgumentError)
    end

    it "does nothing when the choice is skipped" do
      attack!
      block!(blocker)
      game.skip_choice!
      game.settle!

      expect(treasures).to be_empty
    end

    it "does not trigger when a different creature is blocked" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      attack!(bears)
      block!(blocker, attacker: bears)

      expect(game.choices).to be_empty
      expect(treasures).to be_empty
    end

    it "does not trigger when unblocked" do
      attack!

      expect(game.choices).to be_empty
    end
  end

  describe "mode two" do
    let!(:horse) { ResolvePermanent("Armored Warhorse", owner: p1) }
    let!(:other_horse) { ResolvePermanent("Armored Warhorse", owner: p1) }

    before do
      attack!
      block!(blocker)
    end

    it "gives the opponent the Horse, removes Bill from combat and creates three Treasures" do
      game.resolve_choice!(mode: described_class::ModeChoice::HORSE)
      game.resolve_choice!(target: horse)
      game.settle!

      expect(horse.controller).to eq(p2)
      expect(p2.creatures).to include(horse)
      expect(other_horse.controller).to eq(p1)
      expect(bill.attacking?).to be(false)
      expect(treasures.count).to eq(3)
    end

    it "only offers Horses you control" do
      theirs = ResolvePermanent("Armored Warhorse", owner: p2)
      game.resolve_choice!(mode: described_class::ModeChoice::HORSE)

      expect(game.choices.last.choices).to contain_exactly(horse, other_horse)
      expect(game.choices.last.choices).not_to include(theirs, blocker)
    end

    it "gives nothing when the Horse choice is skipped" do
      game.resolve_choice!(mode: described_class::ModeChoice::HORSE)
      game.skip_choice!
      game.settle!

      expect(horse.controller).to eq(p1)
      expect(bill.attacking?).to be(true)
      expect(treasures).to be_empty
    end
  end
end
