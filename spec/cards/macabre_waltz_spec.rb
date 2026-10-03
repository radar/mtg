# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MacabreWaltz do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:ghoul) { Card("Diregraf Ghoul", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }
  let(:waltz) { Card("Macabre Waltz", owner: p1) }

  def cast_waltz(*targets)
    p1.hand.add(waltz)
    p1.add_mana(black: 2)
    cast_and_resolve(card: waltz) do |a|
      a.targeting(*targets) if targets.any?
      a.pay_mana(black: 1, generic: { black: 1 })
    end
  end

  it "returns up to two creature cards to your hand, then discards a card" do
    p1.graveyard.add(bears)
    p1.graveyard.add(ghoul)
    cast_waltz(bears, ghoul)

    expect(bears.zone).to be_hand
    expect(ghoul.zone).to be_hand
    expect(game.choices.last).to be_a(Magic::Choice::Discard)

    discard = p1.hand.cards.first
    game.resolve_choice!(card: discard)
    expect(discard.zone).to be_graveyard
  end

  it "can return just one card" do
    p1.graveyard.add(bears)
    cast_waltz(bears)

    expect(bears.zone).to be_hand
  end

  it "can't target a noncreature card" do
    p1.graveyard.add(bolt)
    p1.hand.add(waltz)

    expect { cast_action(card: waltz, targeting: bolt) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target a creature in an opponent's graveyard" do
    theirs = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(theirs)
    p1.hand.add(waltz)

    expect { cast_action(card: waltz, targeting: theirs) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
