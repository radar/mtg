require 'spec_helper'

RSpec.describe Magic::Cards::Cancel do
  include_context "two player game"

  let(:sol_ring) { Card("Sol Ring") }
  subject(:cancel) { Card("Cancel") }

  before do
    p1.hand.add(cancel)
    p2.hand.add(sol_ring)
  end

  context "counters a Sol Ring" do
    it "sol ring never enters the battlefield" do
      p2.add_mana(red: 1)
      action = p2.cast(card: sol_ring) do
        _1.pay_mana(generic: { red: 1 })
      end

      p1.add_mana(blue: 3)
      action_2 = p1.cast(card: cancel) do
        _1.pay_mana(blue: 2, generic: { blue: 1 })
        _1.targeting(action)
      end

      game.stack.resolve!
      expect(cancel.zone).to be_graveyard
      expect(sol_ring.zone).to be_graveyard
    end
  end
end
