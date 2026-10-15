# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RecruiterOfTheGuard do
  include_context "two player game"

  let!(:small) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } }
  let!(:big) { Card("Felidar Savior", owner: p1).tap { p1.library.add(_1) } }
  let!(:spell) { Card("Lightning Bolt", owner: p1).tap { p1.library.add(_1) } }

  def enter_recruiter
    ResolvePermanent("Recruiter Of The Guard", owner: p1)
    game.settle!
  end

  it "is a 1/1 Human Soldier" do
    recruiter = ResolvePermanent("Recruiter Of The Guard", owner: p1, settle: false)

    expect([recruiter.power, recruiter.toughness]).to eq([1, 1])
    expect(recruiter.type?("Human")).to be(true)
    expect(recruiter.type?("Soldier")).to be(true)
  end

  it "may search for a creature card with toughness 2 or less and put it into your hand" do
    enter_recruiter
    game.resolve_choice!
    search = game.choices.last

    expect(search.choices.to_a).to contain_exactly(small)
    game.resolve_choice!(targets: [small])

    expect(p1.hand).to include(small)
    expect(p1.library).not_to include(small)
  end

  it "does not offer creatures with toughness 3 or more or noncreature cards" do
    enter_recruiter
    game.resolve_choice!

    expect(game.choices.last.choices.to_a).not_to include(big, spell)
  end

  it "reveals the card and shuffles the library" do
    enter_recruiter
    game.resolve_choice!
    expect(p1.library).to receive(:shuffle!).at_least(:once).and_call_original
    game.resolve_choice!(targets: [small])

    expect(game.current_turn.events.any? { _1.is_a?(Magic::Events::CardsRevealed) }).to be(true)
  end

  it "searches nothing when declined" do
    enter_recruiter
    hand_size = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand_size)
    expect(p1.library).to include(small)
    expect(game.choices).to be_empty
  end

  it "does not search the opponent's library" do
    theirs = Card("Wood Elves", owner: p2).tap { p2.library.add(_1) }
    enter_recruiter
    game.resolve_choice!

    expect(game.choices.last.choices.to_a).not_to include(theirs)
  end
end
