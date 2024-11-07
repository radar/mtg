require 'spec_helper'

RSpec.describe Magic::Cards::DoomwakeGiant do
  include_context "two player game"

  subject(:doomwake_giant) { Card("Doomwake Giant") }
  let(:p1_ajanis_pridemate) { ResolvePermanent("Ajani's Pridemate", owner: p1) }
  let(:p2_ajanis_pridemate) { ResolvePermanent("Ajani's Pridemate", owner: p2) }

  context "when doomwake giant enters" do
    before do
      p1_ajanis_pridemate
      p2_ajanis_pridemate
    end

    it "gives all creatures opponent controls -1/-1 until end of turn" do
      p1.add_mana(black: 5)
      p1.cast(card: doomwake_giant) do
        _1.pay_mana(generic: { black: 4 }, black: 1)
      end

      game.stack.resolve!
      game.tick!

      aggregate_failures do
        expect(p1_ajanis_pridemate.power).to eq(2)
        expect(p1_ajanis_pridemate.toughness).to eq(2)

        expect(p2_ajanis_pridemate.power).to eq(1)
        expect(p2_ajanis_pridemate.toughness).to eq(1)
      end
    end
  end

  context "when another enchantment enters" do
    let(:doomwake_giant) { ResolvePermanent("Doomwake Giant") }

    before do
      doomwake_giant
      p1_ajanis_pridemate
      p2_ajanis_pridemate
    end


    let(:griffin_aerie) { Card("Griffin Aerie") }

    it "gives all creatures opponent controls -1/-1 until end of turn" do
      p1.add_mana(white: 2)
      p1.cast(card: griffin_aerie) do
        _1.pay_mana(generic: { white: 1 }, white: 1)
      end

      game.stack.resolve!
      game.tick!

      aggregate_failures do
        expect(p1_ajanis_pridemate.power).to eq(2)
        expect(p1_ajanis_pridemate.toughness).to eq(2)

        expect(p2_ajanis_pridemate.power).to eq(1)
        expect(p2_ajanis_pridemate.toughness).to eq(1)
      end
    end
  end
end
