require 'spec_helper'

RSpec.describe Magic::Cards::RampantGrowth do
  include_context "two player game"

  let(:card) { Card("Rampant Growth") }

  def p1_library
    9.times.map { Card("Forest") }
  end

  it "search for land effect" do
    cast_and_resolve(card: card, player: p1)
    choice = game.choices.last
    expect(choice).to be_a(Magic::Cards::RampantGrowth::Choice)
    game.resolve_choice!(targets: [choice.choices.first])
    forest = game.battlefield.cards.by_name("Forest").first
    expect(forest).to be_tapped
  end
end
