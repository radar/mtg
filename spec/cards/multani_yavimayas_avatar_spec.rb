# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MultaniYavimayasAvatar do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Multani Yavimayas Avatar", owner: p1) }

  it "returns to hand from the graveyard for {1}{G} and returning two lands" do
    forests = 2.times.map { ResolvePermanent("Forest", owner: p1) }
    p1.graveyard.add(card)
    p1.add_mana(green: 2)

    p1.activate_ability(ability: card.graveyard_abilities.first) do |a|
      a.pay_mana(generic: { green: 1 }, green: 1).pay_return_lands(forests)
    end
    game.stack.resolve!

    expect(p1.hand.cards).to include(card)
    expect(p1.graveyard.cards).not_to include(card)
    expect(p1.lands).to be_empty
    expect(p1.hand.cards.map(&:name)).to include("Forest")
  end

  it "cannot be paid for with fewer than two lands" do
    forest = ResolvePermanent("Forest", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(green: 2)

    expect do
      p1.activate_ability(ability: card.graveyard_abilities.first) do |a|
        a.pay_mana(generic: { green: 1 }, green: 1).pay_return_lands([forest])
      end
    end.to raise_error(/Return exactly 2/)
  end

  it "cannot be activated from the battlefield" do
    permanent = ResolvePermanent("Multani Yavimayas Avatar", owner: p1)
    p1.add_mana(green: 2)

    expect(permanent.activated_abilities).to be_empty
    expect(card.graveyard_abilities.first).not_to be_requirements_met
  end

  it "cannot be activated from hand" do
    p1.hand.add(card)

    expect(card.graveyard_abilities.first).not_to be_requirements_met
  end
end
