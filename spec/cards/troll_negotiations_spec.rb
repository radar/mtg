# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TrollNegotiations do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:card) { Card("Troll Negotiations") }

  it "puts two +1/+1 counters on my creature, then it fights theirs" do
    p1.add_mana(green: 4)
    p1.cast(card: card) do
      _1.targeting(mine, theirs)
      _1.pay_mana(generic: { green: 2 }, green: 2)
    end
    game.stack.resolve!
    game.tick!

    expect(mine.power).to eq(4)
    expect(mine.toughness).to eq(4)
    expect(theirs.card.zone).to be_graveyard
    expect(mine.damage).to eq(2)
  end
end
