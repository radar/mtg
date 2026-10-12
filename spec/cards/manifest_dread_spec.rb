# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ManifestDread do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Manifest Dread", owner: p1).tap { p1.hand.add(_1) } }

  def cast!
    p1.add_mana(green: 2)
    p1.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
  end

  it "puts one of the top two cards onto the battlefield face down as a 2/2 creature and the other into the graveyard" do
    top, second = p1.library.first(2)
    cast!

    expect(game.choices.last).to be_a(Magic::Choice::ManifestDread)
    game.resolve_choice!(target: second)

    manifested = p1.permanents.find(&:face_down?)
    expect(manifested.card).to eq(second)
    expect([manifested.power, manifested.toughness]).to eq([2, 2])
    expect(top.zone).to be_graveyard
  end

  it "goes to the graveyard itself" do
    cast!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(spell.zone).to be_graveyard
  end
end
