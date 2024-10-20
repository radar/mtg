require 'spec_helper'

RSpec.describe Magic::Cards::SatyrEnchanter do
  include_context "two player game"

  subject! { ResolvePermanent("Satyr Enchanter", owner: p1) }

  context "when enchantment is cast" do
    let(:doubling_season) { Card("Doubling Season") }

    it "draws a card" do
      p1.add_mana(green: 5)
      expect(p1).to receive(:draw!)
      p1.cast(card: doubling_season) do
        _1.pay_mana(green: 1, generic: { green: 4 })
      end

      game.tick!
    end
  end
end
