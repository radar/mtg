# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Quarrel do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Ordinary Bear", owner: p1) }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_quarrel(*targets)
    card = Card("Quarrel", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  it "has your creature deal damage equal to its power to the opponent's creature" do
    cast_quarrel(bear, victim)

    expect(victim.card.zone).to be_graveyard
  end

  it "deals damage only one way" do
    cast_quarrel(bear, victim)

    expect(bear.damage).to eq(0)
  end

  it "can't target your own creature as the victim" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    expect { cast_quarrel(bear, other) }.to raise_error(StandardError)
  end
end
