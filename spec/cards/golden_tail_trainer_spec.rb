# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoldenTailTrainer do
  include_context "two player game"

  let!(:trainer) { ResolvePermanent("Golden-Tail Trainer", owner: p1) }

  before { go_to_main_phase! }

  it "makes Aura spells cost {X} less, where X is its power" do
    target = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Utter Insignificance", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(target) }
    game.stack.resolve!
    game.settle!

    expect(game.battlefield.permanents.map(&:name)).to include("Utter Insignificance")
  end

  it "gives other modified creatures you control +X/+X when it attacks" do
    modified = ResolvePermanent("Grizzly Bears", owner: p1)
    plain = ResolvePermanent("Wood Elves", owner: p1)
    modified.add_counter("+1/+1")
    game.tick!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(trainer, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.settle!
    game.tick!

    expect([modified.power, modified.toughness]).to eq([4, 4])
    expect([plain.power, plain.toughness]).to eq([1, 1])
    expect([trainer.power, trainer.toughness]).to eq([1, 3])
  end
end
