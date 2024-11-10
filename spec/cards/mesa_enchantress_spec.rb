require 'spec_helper'

RSpec.describe Magic::Cards::MesaEnchantress do
  include_context "two player game"

  subject! { ResolvePermanent("Mesa Enchantress", owner: p1) }

  context "when enchantment is cast" do
    let(:doubling_season) { Card("Doubling Season") }

    it "draws a card" do
      p1.add_mana(green: 5)
      p1.cast(card: doubling_season) do
        _1.pay_mana(green: 1, generic: { green: 4 })
      end

      game.tick!

      expect(p1).to receive(:draw!)
      expect(game.choices.last).to be_a(Magic::Cards::MesaEnchantress::Choice)

      game.resolve_choice!

    end
  end
end
