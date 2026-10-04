# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MiaraThornOfTheGlade do
  include_context "two player game"

  let!(:miara) { ResolvePermanent("Miara, Thorn Of The Glade", owner: p1) }

  before { p1.add_mana(black: 1) }

  context "another Elf you control dies" do
    let!(:elf) { ResolvePermanent("Elvish Warmaster", owner: p1) }

    it "pays {1} and 1 life to draw a card" do
      hand_size = p1.hand.count
      elf.destroy!
      game.settle!
      game.resolve_choice!(payment: { black: 1 })

      expect(p1.life).to eq(19)
      expect(p1.hand.count).to eq(hand_size + 1)
      expect(p1.mana_pool[:black]).to eq(0)
    end

    it "does nothing when declined" do
      hand_size = p1.hand.count
      elf.destroy!
      game.settle!
      game.skip_choice!

      expect(p1.life).to eq(20)
      expect(p1.hand.count).to eq(hand_size)
    end
  end

  context "Miara dies" do
    it "triggers for itself" do
      hand_size = p1.hand.count
      miara.destroy!
      game.settle!
      game.resolve_choice!(payment: { black: 1 })

      expect(p1.hand.count).to eq(hand_size + 1)
    end
  end

  context "a non-Elf you control dies" do
    it "does not trigger" do
      ResolvePermanent("Grizzly Bears", owner: p1).destroy!
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  context "an Elf an opponent controls dies" do
    it "does not trigger" do
      ResolvePermanent("Elvish Warmaster", owner: p2).destroy!
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
