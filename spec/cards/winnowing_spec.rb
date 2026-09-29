# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Winnowing do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Winnowing", owner: p1) }

  def cast
    p1.hand.add(card)
    p1.add_mana(white: 6)
    p1.cast(card:) { _1.pay_mana(generic: { white: 4 }, white: 2) }
    game.stack.resolve!
  end

  it "has convoke" do
    expect(card.convoke?).to be(true)
  end

  it "has each player keep the chosen creature and any that share a creature type with it" do
    mine_kept = ResolvePermanent("Skyway Sniper", owner: p1)        # Elf
    mine_elf = ResolvePermanent("Skyway Sniper", owner: p1)         # shares Elf
    mine_other = ResolvePermanent("Grizzly Bears", owner: p1)       # Bear: no Elf
    theirs_kept = ResolvePermanent("Grizzly Bears", owner: p2)
    theirs_other = ResolvePermanent("Skyway Sniper", owner: p2)
    cast
    game.resolve_choice!(target: mine_kept)
    game.resolve_choice!(target: theirs_kept)
    game.settle!

    expect(mine_kept.zone).to be_battlefield
    expect(mine_elf.zone).to be_battlefield
    expect(mine_other.card.zone).to be_graveyard
    expect(theirs_kept.zone).to be_battlefield
    expect(theirs_other.card.zone).to be_graveyard
  end

  it "keeps everything you control when the chosen creature is a changeling" do
    changeling = ResolvePermanent("Chomping Changeling", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
    cast
    game.resolve_choice!(target: changeling)
    game.resolve_choice!(target: theirs)
    game.settle!

    expect(bears.zone).to be_battlefield
  end

  it "sacrifices nothing extra when each player has a single creature" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
    cast
    game.settle!

    expect([mine.zone, theirs.zone]).to all(be_battlefield)
  end

  it "does nothing with no creatures" do
    cast

    expect(game.choices).to be_empty
  end

  it "skips a player with no creatures" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    other = ResolvePermanent("Courser Of Kruphix", owner: p1)
    cast
    game.resolve_choice!(target: mine)
    game.settle!

    expect(other.card.zone).to be_graveyard
  end
end
