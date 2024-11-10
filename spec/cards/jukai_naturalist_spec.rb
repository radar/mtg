require 'spec_helper'

RSpec.describe Magic::Cards::JukaiNaturalist do
  include_context "two player game"

  subject! { ResolvePermanent("Jukai Naturalist") }

  it "has lifelink" do
    expect(subject).to have_keyword(:lifelink)
  end

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
end
