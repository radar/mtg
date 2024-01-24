# Ghostly Pilferer {1}{U}
# Creature — Spirit Rogue
# Whenever Ghostly Pilferer becomes untapped, you may pay {2}. If you do, draw a card.
# Whenever an opponent casts a spell from anywhere other than their hand, draw a card.
# Discard a card: Ghostly Pilferer can't be blocked this turn.
# 2/1

require 'spec_helper'

RSpec.describe Magic::Cards::GhostlyPilferer do
  include_context "two player game"

  let!(:ghostly_pilferer) { ResolvePermanent("Ghostly Pilferer", owner: p1) }

  context "when it becomes untapped, pay 2 to draw a card" do
    it "cost is paid, draws a card" do
      ghostly_pilferer.tap!
      ghostly_pilferer.untap!

      p1.add_mana(blue: 2)
      expect(p1).to receive(:draw!)
      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice)
      choice.pay(p1, generic: { blue: 2 })
      choice.resolve!
    end
  end

  context "when it becomes untapped, does not pay" do
    it "cost is not paid, no card draw" do
      ghostly_pilferer.tap!
      ghostly_pilferer.untap!

      p1.add_mana(blue: 2)
      expect(p1).not_to receive(:draw!)
      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice)
      game.resolve_choice!
      expect(game.choices).to be_none
    end
  end
end
