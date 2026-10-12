# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TrialOfAgony do
  include_context "two player game"

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p2) }

  before { go_to_main_phase! }

  def cast(*targets)
    p1.add_mana(red: 1)
    p1.cast(card: Card("Trial Of Agony", owner: p1)) { _1.pay_mana(red: 1).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  it "has the opponent choose a creature to take 5 damage while the other can't block" do
    cast(bears, elves)

    expect(game.choices.last.player).to eq(p2)
    game.resolve_choice!(target: bears)
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])
    expect(elves.zone).to be_battlefield
    expect(elves.can_block?(mine)).to be(false)
  end

  it "damages the other creature when the opponent chooses it" do
    cast(bears, elves)
    game.resolve_choice!(target: elves)
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to eq(["Wood Elves"])
    expect(bears.can_block?(mine)).to be(false)
  end

  it "can't target creatures controlled by different players" do
    expect { cast(mine, bears) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target the same creature twice" do
    expect { cast(bears, bears) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
