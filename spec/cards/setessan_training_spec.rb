# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::SetessanTraining do
  include_context "two player game"

  let(:card) { Card("Setessan Training") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  context "when entering the battlefield" do
    it "draws a card for the controller" do
      p1.add_mana(green: 2)
      expect(p1).to receive(:draw!)

      p1.cast(card: card) do
        _1.pay_mana(generic: { green: 1 }, green: 1)
        _1.targeting(wood_elves)
      end

      game.stack.resolve!
      game.tick!
    end
  end

  context "when attached to a creature" do
    before do
      p1.add_mana(green: 2)
      p1.cast(card: card) do
        _1.pay_mana(generic: { green: 1 }, green: 1)
        _1.targeting(wood_elves)
      end
      game.stack.resolve!
      game.tick!
    end

    it "gives the enchanted creature +1/+0" do
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(1)
    end

    it "gives the enchanted creature trample" do
      expect(wood_elves).to be_trample
    end
  end
end
