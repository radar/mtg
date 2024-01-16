require 'spec_helper'

RSpec.describe Magic::Cards::Counterspell do
  include_context "two player game"

  let(:sol_ring) { Card("Sol Ring", game: game, owner: p1) }
  let(:annul) { Card("Annul", game: game, owner: p2) }
  let(:counterspell) { Card("Counterspell", owner: p1) }

  context "counters annul, which was countering sol ring" do
    it "sol ring enters the battlefield" do
      p1.add_mana(red: 1)
      sol_ring_action = cast_action(card: sol_ring, player: p1)
      sol_ring_action.pay_mana(generic: { red: 1 } )
      game.take_action(sol_ring_action)

      p2.add_mana(blue: 1)
      annul_action = cast_action(card: annul, player: p2).targeting(sol_ring_action)
      annul_action.pay_mana(blue: 1)
      game.take_action(annul_action)

      p1.add_mana(blue: 2)
      counterspell_action = cast_action(card: counterspell, player: p1).targeting(annul_action)
      counterspell_action.pay_mana(blue: 2)
      game.take_action(counterspell_action)

      game.stack.resolve!
      expect(annul.zone).to be_graveyard

      expect(p1.permanents.by_name("Sol Ring").count).to eq(1)
    end
  end
end
