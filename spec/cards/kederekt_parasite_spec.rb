# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KederektParasite do
  include_context "two player game"

  let!(:parasite) { ResolvePermanent("Kederekt Parasite", owner: p1) }

  context "when you control a red permanent" do
    before { ResolvePermanent("Gleeful Arsonist", owner: p1) }

    it "lets you deal 1 damage to an opponent who draws" do
      p2.draw!
      game.settle!
      game.resolve_choice!
      game.settle!

      expect(p2.life).to eq(19)
    end

    it "lets you decline" do
      p2.draw!
      game.settle!
      game.skip_choice!

      expect(p2.life).to eq(20)
    end

    it "ignores your own draws" do
      p1.draw!
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  it "does nothing without a red permanent" do
    p2.draw!
    game.settle!

    expect(game.choices).to be_empty
  end
end
