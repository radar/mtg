# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LasydProwler do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Lasyd Prowler", owner: p1) }

  it "may mill cards equal to the number of lands you control when it enters" do
    2.times { ResolvePermanent("Forest", owner: p1) }
    ResolvePermanent("Lasyd Prowler", owner: p1)
    game.resolve_choice!

    expect(p1.graveyard.cards.size).to eq(2)
  end

  it "renews for {1}{G}: X +1/+1 counters, X being the land cards in your graveyard" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    2.times { p1.graveyard.add(Card("Forest", owner: p1)) }
    p1.graveyard.add(card)
    p1.add_mana(green: 2)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect([bear.power, bear.toughness]).to eq([4, 4])
  end
end
