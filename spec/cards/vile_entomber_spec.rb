# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VileEntomber do
  include_context "two player game"

  let(:target_card) { Card("Grizzly Bears", owner: p1) }
  let(:other_card) { Card("Boltwave", owner: p1) }

  def enter!
    ResolvePermanent("Vile Entomber", owner: p1, settle: false)
    game.settle!
  end

  it "is a 2/2 Zombie Warlock with deathtouch" do
    entomber = ResolvePermanent("Vile Entomber", owner: p1)

    expect([entomber.power, entomber.toughness]).to eq([2, 2])
    expect(entomber.has_keyword?(:deathtouch)).to eq(true)
  end

  it "searches your library for any card and puts it into your graveyard" do
    p1.library.add(target_card)
    p1.library.add(other_card)
    enter!
    choice = game.choices.last

    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    expect(choice.choices).to include(target_card, other_card)

    game.resolve_choice!(targets: [other_card])

    expect(other_card.zone).to be_graveyard
    expect(p1.library.cards).to include(target_card)
    expect(p1.library.cards).not_to include(other_card)
  end

  it "doesn't search the opponent's library" do
    theirs = Card("Grizzly Bears", owner: p2)
    p2.library.add(theirs)
    enter!

    expect(game.choices.last.choices).not_to include(theirs)
  end

  it "may find nothing" do
    p1.library.add(target_card)
    enter!
    game.resolve_choice!(targets: [])

    expect(p1.graveyard.cards).to be_empty
  end
end
