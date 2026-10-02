# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BiteDown do
  include_context "two player game"

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Wood Elves", owner: p2) }
  let(:spell) { Card("Bite Down", owner: p1) }

  def bite(biter, victim)
    p1.add_mana(green: 2)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(biter, victim) }
    game.stack.resolve!
    game.tick!
  end

  it "has your creature deal damage equal to its power to a creature you don't control" do
    bite(mine, theirs)

    expect(p2.graveyard.cards.map(&:name)).to include("Wood Elves")
    expect(mine.damage).to eq(0)
  end

  it "can't target a creature you control as the victim" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 2)

    expect { p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(mine, other) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
