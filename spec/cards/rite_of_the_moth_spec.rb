# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RiteOfTheMoth do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:rite) { Card("Rite Of The Moth", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }

  def cast!
    p1.hand.add(rite)
    p1.add_mana(white: 1, black: 3)
    p1.cast(card: rite) { _1.pay_mana(generic: { black: 1 }, white: 1, black: 2).targeting(bears) }
    game.stack.resolve!
    game.settle!
  end

  it "returns target creature card from your graveyard to the battlefield with a finality counter" do
    cast!

    permanent = p1.permanents.find { _1.card == bears }
    expect(permanent).not_to be_nil
    expect(permanent.counters.of_type(Magic::Counters::Finality).count).to eq(1)
  end

  it "exiles the creature instead of letting it die" do
    cast!
    p1.permanents.find { _1.card == bears }.destroy!
    game.settle!

    expect(bears.zone).to be_exile
  end

  it "only targets creature cards in your graveyard" do
    p1.graveyard.add(Card("Forest", owner: p1))
    theirs = Card("Grizzly Bears", owner: p2).tap { p2.graveyard.add(_1) }

    expect(rite.tap { p1.hand.add(_1) }.target_choices).to eq([bears])
    expect(rite.target_choices).not_to include(theirs)
  end

  it "has flashback {3}{W}{W}{B}, then is exiled" do
    p1.graveyard.add(rite)
    p1.add_mana(white: 2, black: 4)
    p1.cast_as(:flashback, card: rite) { _1.pay_mana(generic: { black: 3 }, white: 2, black: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!

    expect(p1.permanents.map(&:card)).to include(bears)
    expect(rite.zone).to be_exile
  end
end
