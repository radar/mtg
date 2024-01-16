require 'spec_helper'

RSpec.describe Magic::Cards::RainOfRevelation do
  include_context "two player game"

  subject { described_class.new(game: game, owner: p1) }

  context "cast" do
    it "draws 3 cards" do
      expect(p1).to receive(:draw!).exactly(3).times
      cast_and_resolve(card: subject, player: p1)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::Discard)
      card = choice.cards.first
      choice.choose(card)

      expect(card.zone).to be_graveyard
    end
  end
end
