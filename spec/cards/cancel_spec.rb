require 'spec_helper'

RSpec.describe Magic::Cards::Cancel do
  include_context "two player game"

  let(:sol_ring) { Card("Sol Ring") }
  subject(:cancel) { described_class.new(game: game) }

  before do
    p1.hand.add(cancel)
    p2.hand.add(sol_ring)
  end

  context "counters a Sol Ring" do
    it "sol ring never enters the battlefield" do
      p2.add_mana(red: 1)
      action = Magic::Actions::Cast.new(player: p2, card: sol_ring)
      action.pay_mana(generic: { red: 1 })
      game.take_action(action)

      p1.add_mana(blue: 3)
      action_2 = Magic::Actions::Cast.new(player: p1, card: cancel)
      action_2.targeting(action)
      action_2.pay_mana(blue: 2, generic: { blue: 1 })
      game.take_action(action_2)

      game.stack.resolve!
      expect(cancel.zone).to be_graveyard
      expect(sol_ring.zone).to be_graveyard
    end
  end
end
