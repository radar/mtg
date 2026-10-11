# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ValgavothsOnslaught do
  include_context "two player game"

  let(:card) { Card("Valgavoths Onslaught", owner: p1).tap { p1.hand.add(_1) } }

  before { go_to_main_phase! }

  def cast(x:)
    p1.add_mana(green: 2 * x + 1)
    p1.cast(card: card, value_for_x: x) { |a| a.pay_mana(green: 1, x: { green: 2 * x }) }
    game.stack.resolve!
  end

  def face_down = p1.permanents.select(&:face_down?)

  it "costs twice X plus {G}" do
    p1.add_mana(green: 4)

    expect { p1.cast(card: card, value_for_x: 2) { |a| a.pay_mana(green: 1, x: { green: 3 }) } }
      .to raise_error(Magic::Costs::Mana::OutstandingBalance)
  end

  it "manifests dread X times, then puts X +1/+1 counters on each of those creatures" do
    cast(x: 2)
    game.resolve_choice!(target: game.choices.last.choices.first)
    expect(face_down.size).to eq(1)
    expect(face_down.first.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)

    game.resolve_choice!(target: game.choices.last.choices.first)
    game.settle!

    expect(face_down.size).to eq(2)
    expect(face_down.map(&:power)).to eq([4, 4])
    expect(face_down.map(&:toughness)).to eq([4, 4])
  end

  it "does nothing for X = 0" do
    cast(x: 0)

    expect(face_down).to be_empty
    expect(game.choices).to be_empty
  end

  it "puts counters only on the creatures it made" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    cast(x: 1)
    game.resolve_choice!(target: game.choices.last.choices.first)
    game.settle!

    expect(face_down.first.power).to eq(3)
    expect(other.power).to eq(2)
  end

  it "keeps going when the library runs out" do
    empty = p1.library.cards.to_a.dup
    empty.each { p1.library.remove(_1) }
    only = Card("Forest", owner: p1).tap { p1.library.add(_1) }
    cast(x: 2)
    game.settle!

    expect(face_down.map(&:card)).to eq([only])
    expect(face_down.first.power).to eq(4)
  end
end
