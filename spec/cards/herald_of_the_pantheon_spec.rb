require "spec_helper"

RSpec.describe Magic::Cards::HeraldOfThePantheon do
  include_context "two player game"

  subject! { ResolvePermanent("Herald of The Pantheon") }

  context "cost reduction" do
    it "reduces the cost of enchantments" do
      cast_action = p1.prepare_cast(card: Card("Nine Lives"))
      expect(cast_action.mana_cost.generic).to eq(0)
      expect(cast_action.mana_cost.white).to eq(2)
    end

    it "does not reduce the cost of non-enchantments" do
      cast_action = p1.prepare_cast(card: Card("Wood Elves"))
      expect(cast_action.mana_cost.generic).to eq(2)
      expect(cast_action.mana_cost.green).to eq(1)
    end
  end

  context "when you cast an enchantment" do
    it "gains life" do
      p1.add_mana(white: 3)
      p1.cast(card: Card("Nine Lives")) do
        _1.auto_pay_mana
      end

      game.stack.resolve!

      expect(p1.life).to eq(21)
    end
  end
end
