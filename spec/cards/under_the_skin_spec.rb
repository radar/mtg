# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnderTheSkin do
  include_context "two player game"

  let(:spell) { Card("Under The Skin", owner: p1).tap { p1.hand.add(_1) } }

  before { go_to_main_phase! }

  def cast!
    p1.add_mana(green: 3)
    p1.cast(card: spell) { _1.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "manifests dread, then may return a permanent card from your graveyard to your hand" do
    old = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
    top, = p1.library.first(2)
    cast!
    game.resolve_choice!(target: top)

    return_choice = game.choices.last
    expect(return_choice).to be_a(Magic::Choice::ReturnFromAmong)
    expect(return_choice.choices).to include(old)
    game.resolve_choice!(target: old)

    expect(p1.permanents.count(&:face_down?)).to eq(1)
    expect(old.zone).to be_hand
  end

  it "includes the card put into the graveyard by manifest dread" do
    top, second = p1.library.first(2)
    cast!
    game.resolve_choice!(target: top)

    expect(game.choices.last.choices).to include(second)
  end

  it "does not offer instants or sorceries from the graveyard" do
    Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) }
    p1.library.cards.to_a.dup.each { p1.library.remove(_1) }
    Card("Forest", owner: p1).tap { p1.library.add(_1) }
    cast!

    expect(game.choices).to be_empty
  end

  it "may return nothing" do
    Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
    cast!
    game.resolve_choice!(target: game.choices.last.choices.first)
    game.resolve_choice!(target: nil)

    expect(p1.hand.cards.map(&:name)).not_to include("Grizzly Bears")
  end
end
