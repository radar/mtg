# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HydraTrainer do
  include_context "two player game"

  let!(:trainer) { ResolvePermanent("Hydra Trainer", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: trainer, target: p2)
    current_turn.attackers_declared!
  end

  it "is a 1/1 Human Warrior" do
    expect([trainer.power, trainer.toughness]).to eq([1, 1])
    expect(trainer.type?("Warrior")).to be(true)
  end

  context "exert as it attacks" do
    before do
      bears.add_counter("+1/+1", amount: 2)
      theirs.add_counter("+1/+1")
      attack
    end

    it "gets target creature +X/+X where X is the counters on permanents you control (not the opponent's)" do
      game.resolve_choice!
      game.resolve_choice!(target: bears)
      game.settle!

      expect(trainer.cannot_untap_next_turn).to be true
      expect([bears.power, bears.toughness]).to eq([6, 6])
    end

    it "can target an opponent's creature" do
      game.resolve_choice!
      game.resolve_choice!(target: theirs)
      game.settle!

      expect([theirs.power, theirs.toughness]).to eq([5, 5])
    end

    it "does nothing and doesn't exert if declined" do
      game.skip_choice!
      game.settle!

      expect(trainer.cannot_untap_next_turn).to be_falsy
      expect([bears.power, bears.toughness]).to eq([4, 4])
    end
  end

  context "{2}{G}: Adapt 2" do
    def adapt
      p1.add_mana(green: 3)
      p1.activate_ability(ability: trainer.activated_abilities.first) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }
      game.stack.resolve!
      game.settle!
    end

    it "puts two +1/+1 counters on it if it has none" do
      adapt

      expect([trainer.power, trainer.toughness]).to eq([3, 3])
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      adapt

      expect([trainer.power, trainer.toughness]).to eq([3, 3])
    end
  end
end
