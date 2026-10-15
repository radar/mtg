# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Brainsurge do
  include_context "two player game"

  let(:card) { Card("Brainsurge", owner: p1) }

  def cast_brainsurge
    p1.hand.add(card)
    p1.add_mana(blue: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "draws four cards, then asks for two cards from hand to put on top" do
    before_count = p1.hand.cards.size
    cast_brainsurge
    expect(p1.hand.cards.size).to eq(before_count + 4)
    expect(game.choices.last.choices).to match_array(p1.hand.cards.to_a)
  end

  it "puts the chosen cards on top of the library in the given order, top first" do
    cast_brainsurge
    first, second, *rest = p1.hand.cards.to_a
    game.resolve_choice!(targets: [second, first])
    expect(p1.library.cards.first(2)).to eq([second, first])
    expect(p1.hand.cards.to_a).to eq(rest)
    expect(second.zone).to eq(p1.library)
  end

  it "rejects the wrong number of cards" do
    cast_brainsurge
    one = p1.hand.cards.first
    expect { game.resolve_choice!(targets: [one]) }.to raise_error(ArgumentError)
  end

  it "rejects cards not in hand" do
    cast_brainsurge
    outside = p1.library.cards.first
    expect { game.resolve_choice!(targets: [p1.hand.cards.first, outside]) }.to raise_error(ArgumentError)
  end

  it "puts two cards back when the choice is skipped" do
    cast_brainsurge
    size = p1.hand.cards.size
    game.skip_choice!
    expect(p1.hand.cards.size).to eq(size - 2)
  end
end
