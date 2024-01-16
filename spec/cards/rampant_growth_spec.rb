require 'spec_helper'

RSpec.describe Magic::Cards::RampantGrowth do
  include_context "two player game"

  let(:card) { Card("Rampant Growth") }

  def p1_library
    9.times.map { Card("Forest") }
  end

  it "search for land effect" do
    cast_and_resolve(card: card, player: p1)
    effect = game.effects.first
    expect(effect).to be_a(Magic::Effects::SearchLibraryForBasicLand)
    game.resolve_pending_effect(effect.choices.first) # A Forest
    forest = game.battlefield.cards.by_name("Forest").first
    expect(forest).to be_tapped
  end
end
