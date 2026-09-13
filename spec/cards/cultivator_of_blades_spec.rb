# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CultivatorOfBlades do
  include_context "two player game"

  subject!(:cultivator) { ResolvePermanent("Cultivator of Blades", owner: p1) }

  context "Fabricate 2" do
    it "presents a modal choice" do
      expect(game.choices.last).to be_a(described_class::FabricateChoice)
    end

    it "puts two +1/+1 counters on itself when that mode is chosen" do
      game.resolve_choice!(mode: described_class::FabricateChoice::COUNTERS)
      game.tick!

      expect(cultivator.power).to eq(3)
      expect(cultivator.toughness).to eq(3)
    end

    it "creates two 1/1 Servo tokens when that mode is chosen" do
      game.resolve_choice!(mode: described_class::FabricateChoice::TOKENS)

      servos = p1.creatures.by_name("Servo")
      expect(servos.count).to eq(2)
      expect(servos.first.power).to eq(1)
      expect(servos.first.toughness).to eq(1)
    end
  end

  context "attack trigger" do
    before do
      game.resolve_choice!(mode: described_class::FabricateChoice::COUNTERS)
      game.tick!
    end

    context "when attacking with another creature" do
      let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

      before do
        skip_to_combat!
        current_turn.declare_attackers!
        p1.declare_attacker(attacker: cultivator, target: p2)
        p1.declare_attacker(attacker: bears, target: p2)
        current_turn.attackers_declared!
      end

      it "presents a choice to pump other attackers" do
        expect(game.choices.last).to be_a(described_class::PumpChoice)
      end

      it "boosts the other attacking creature by its power when accepted" do
        game.resolve_choice!
        game.tick!

        expect(bears.power).to eq(5)
        expect(bears.toughness).to eq(5)
      end

      it "does not boost itself" do
        game.resolve_choice!
        game.tick!

        expect(cultivator.power).to eq(3)
        expect(cultivator.toughness).to eq(3)
      end

      it "does not boost the other attacker when declined" do
        game.skip_choice!

        expect(bears.power).to eq(2)
        expect(bears.toughness).to eq(2)
      end
    end

    context "when attacking alone" do
      before do
        skip_to_combat!
        current_turn.declare_attackers!
        p1.declare_attacker(attacker: cultivator, target: p2)
        current_turn.attackers_declared!
      end

      it "does not present a choice" do
        expect(game.choices.last).to be_nil
      end
    end
  end
end
