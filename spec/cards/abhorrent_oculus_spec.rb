# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AbhorrentOculus do
  include_context "two player game"

  let(:card) { Card("Abhorrent Oculus", owner: p1).tap { p1.hand.add(_1) } }

  def fill_graveyard!(count)
    count.times.map { Card("Forest", owner: p1).tap { p1.graveyard.add(_1) } }
  end

  def cast!(exiling:)
    p1.add_mana(blue: 3)
    p1.cast(card: card) { _1.pay_mana(generic: { blue: 2 }, blue: 1).pay_additional_cost(Magic::Costs::ExileFromGraveyard, exiling) }
    game.stack.resolve!
    game.settle!
  end

  before { go_to_main_phase! }

  it "exiles six cards from your graveyard as it is cast" do
    graveyard = fill_graveyard!(7)
    cast!(exiling: graveyard.first(6))

    expect(graveyard.first(6).map(&:zone)).to all(be_exile)
    expect(graveyard.last.zone).to be_graveyard
    permanent = p1.permanents.find { _1.card == card }
    expect([permanent.power, permanent.toughness]).to eq([5, 5])
    expect(permanent).to have_keyword(:flying)
  end

  it "can't be cast with fewer than six cards" do
    graveyard = fill_graveyard!(6)

    expect { cast!(exiling: graveyard.first(5)) }.to raise_error(ArgumentError)
  end

  it "can't exile cards from another graveyard" do
    fill_graveyard!(5)
    theirs = Card("Forest", owner: p2).tap { p2.graveyard.add(_1) }

    expect { cast!(exiling: [*p1.graveyard.cards.to_a, theirs]) }.to raise_error(ArgumentError)
  end

  it "manifests dread at the beginning of each opponent's upkeep" do
    ResolvePermanent("Abhorrent Oculus", owner: p1)
    game.settle!
    game.next_turn
    current_turn.untap!
    current_turn.upkeep!
    game.settle!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  it "doesn't trigger at its controller's own upkeep" do
    ResolvePermanent("Abhorrent Oculus", owner: p1)
    game.settle!
    game.next_turn
    game.next_turn
    current_turn.untap!
    current_turn.upkeep!
    game.settle!

    expect(game.choices).to be_empty
  end
end
