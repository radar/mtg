# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RoamersRoutine do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Roamer's Routine", owner: p1) }

  def p1_library = 9.times.map { Card("Forest") }

  def fetch_forest
    game.stack.resolve!
    choice = game.choices.last
    game.resolve_choice!(targets: [choice.choices.first])
    game.battlefield.cards.by_name("Forest").first
  end

  it "puts a basic land from the library onto the battlefield tapped" do
    p1.add_mana(green: 3)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 2 }, green: 1) }

    expect(fetch_forest).to be_tapped
    expect(card.zone).to be_graveyard
  end

  it "can be harmonized from the graveyard for {4}{G}, then is exiled" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(green: 3)

    p1.cast(card: card, harmonize: true) do |a|
      a.harmonize_tap(bear)
      a.pay_mana(generic: { green: 2 }, green: 1)
    end

    expect(fetch_forest).to be_tapped
    expect(card.zone).to be_exile
  end
end
