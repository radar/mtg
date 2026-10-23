# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DogUmbra do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_umbra(target)
    p1.add_mana(white: 2)
    p1.cast(card: Card("Dog Umbra", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  def umbra = game.battlefield.permanents.find { _1.name == "Dog Umbra" }

  context "on a creature its controller controls" do
    before { cast_umbra(bears) }

    it "has umbra armor" do
      bears.destroy!
      game.settle!

      expect(bears.zone).to eq(game.battlefield)
      expect(umbra).to be_nil
    end

    it "doesn't stop the creature attacking" do
      expect(bears.can_attack?).to eq(true)
    end
  end

  context "on a creature another player controls" do
    let!(:ogre) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before { cast_umbra(ogre) }

    it "stops it attacking or blocking" do
      expect(ogre.can_attack?).to eq(false)
      expect(ogre.can_block?(bears)).to eq(false)
    end

    it "has no umbra armor" do
      ogre.destroy!
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end
end
