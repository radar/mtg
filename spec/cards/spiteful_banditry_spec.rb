# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpitefulBanditry do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:theirs2) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:card) { Card("Spiteful Banditry", owner: p1).tap { p1.hand.add(_1) } }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  def cast(x:)
    p1.add_mana(red: 2 + x)
    p1.cast(card: card, value_for_x: x) { _1.pay_mana(red: 2, x: { red: x }) }
    game.stack.resolve!
    game.settle!
    game.stack.resolve! until game.stack.empty?
    game.settle!
  end

  it "deals X damage to each creature when it enters" do
    cast(x: 1)

    expect(mine.damage).to eq(1)
    expect(theirs.damage).to eq(1)
    expect(theirs2.damage).to eq(1)
  end

  it "kills creatures with toughness X or less, and deals nothing for X = 0" do
    cast(x: 0)
    expect(mine.damage).to eq(0)

    expect(theirs.zone).to be_battlefield
  end

  it "creates a Treasure when opponent creatures die in the ETB wipe" do
    cast(x: 2)

    expect(p1.creatures).to be_empty
    expect(treasures.count).to eq(1)
  end

  context "with it on the battlefield" do
    before { ResolvePermanent("Spiteful Banditry", owner: p1) }

    it "creates a Treasure once when several opponent creatures die together" do
      theirs.destroy!
      theirs2.destroy!
      game.settle!

      expect(treasures.count).to eq(1)
    end

    it "triggers only once each turn" do
      theirs.destroy!
      game.settle!
      theirs2.destroy!
      game.settle!

      expect(treasures.count).to eq(1)
    end

    it "triggers again on a later turn" do
      theirs.destroy!
      game.settle!
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      go_to_main_phase_for!(p2)
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      go_to_main_phase_for!(p1)
      theirs2.destroy!
      game.settle!

      expect(treasures.count).to eq(2)
    end

    it "does not trigger when your own creature dies" do
      mine.destroy!
      game.settle!

      expect(treasures).to be_empty
    end
  end
end
