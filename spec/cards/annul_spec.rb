require 'spec_helper'

RSpec.describe Magic::Cards::Annul do
  include_context "two player game"

  let(:sol_ring) { Magic::Cards::SolRing.new(game: game, controller: p2)}
  subject(:annul) { described_class.new(game: game, controller: p1) }

  context "counters a Sol Ring" do
    it "sol ring never enters the battlefield" do
      p2.add_mana(red: 1)
      action = Magic::Actions::Cast.new(player: p2, card: sol_ring)
      action.pay_mana(generic: { red: 1 })
      game.take_action(action)

      p1.add_mana(blue: 1)
      action_2 = Magic::Actions::Cast.new(player: p1, card: annul)
      action_2.targeting(action)
      action_2.pay_mana(blue: 1)
      game.take_action(action_2)

      game.stack.resolve!
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_graveyard
    end

    it "cannot target a thing that is not an artifact or enchantment" do
      p2.add_mana(green: 3)
      action = Magic::Actions::Cast.new(player: p2, card: Card("Wood Elves"))
      action.pay_mana(generic: { green: 2 }, green: 1)

      p1.add_mana(blue: 1)
      action_2 = Magic::Actions::Cast.new(player: p2, card: annul)
      expect(action_2.can_target?(action)).to eq(false)
    end
  end
end
