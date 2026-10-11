# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OverlordOfTheBalemurk do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Overlord Of The Balemurk", owner: p1).tap { p1.hand.add(_1) } }

  def cast_impending!
    p1.add_mana(black: 2)
    p1.cast_as(:impending, card: card) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "enters with five time counters when cast for {1}{B}" do
    cast_impending!

    expect(p1.permanents.find { _1.card == card }.counters.of_type(Magic::Counters::Time).count).to eq(5)
  end

  it "mills four cards, then may return a non-Avatar creature card from your graveyard to your hand" do
    bears = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
    cast_impending!

    expect(p1.graveyard.cards.count).to be >= 5
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::ReturnFromAmong)
    expect(choice.choices).to include(bears)
    game.resolve_choice!(target: bears)
    expect(bears.zone).to be_hand
  end

  it "doesn't offer an Avatar creature card or a noncreature card" do
    avatar = Card("Overlord Of The Mistmoors", owner: p1).tap { p1.graveyard.add(_1) }
    cast_impending!

    expect(game.choices.last&.choices.to_a).not_to include(avatar) if game.choices.any?
    expect(game.choices.last&.choices.to_a || []).to all(satisfy { !_1.type?("Avatar") })
  end

  it "offers a planeswalker card" do
    walker = Card("Garruk Unleashed", owner: p1).tap { p1.graveyard.add(_1) }
    cast_impending!

    expect(game.choices.last.choices).to include(walker)
  end

  it "may return nothing" do
    Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
    cast_impending!
    game.skip_choice!

    expect(p1.hand.cards.map(&:name)).not_to include("Grizzly Bears")
  end
end
