require "spec_helper"

# arena checks what a player could do on a copy of the game (Marshal.load(Marshal.dump(game))), so nothing a pending
# choice holds may be uncopyable, a lambda above all.
RSpec.describe "Choices in a game that is copied with Marshal" do
  include_context "two player game"

  def copyable!
    expect { Marshal.load(Marshal.dump(game)) }.not_to raise_error
  end

  it "copes with LookAtTopCards, which is built from a filter lambda" do
    game.choices.add(Magic::Choice::LookAtTopCards.new(actor: p1.library.first, amount: 4, filter: ->(card) { card.land? }))

    copyable!
  end

  it "copes with ReturnFromAmong" do
    cards = p1.library.first(3)
    game.choices.add(Magic::Choice::ReturnFromAmong.new(actor: cards.first, cards: cards, filter: ->(card) { card.permanent? }))

    copyable!
  end

  it "copes with PutOntoBattlefieldFromAmong" do
    cards = p1.library.first(3)
    game.choices.add(Magic::Choice::PutOntoBattlefieldFromAmong.new(actor: cards.first, cards: cards, filter: ->(card) { card.permanent? }))

    copyable!
  end

  it "still offers only the cards that pass the filter" do
    lands = p1.library.first(4).select(&:land?)
    choice = Magic::Choice::LookAtTopCards.new(actor: p1.library.first, amount: 4, filter: ->(card) { card.land? })

    expect(choice.choices).to eq(lands)
  end
end
