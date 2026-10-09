# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HobbitHole do
  include_context "two player game"
  before { go_to_main_phase! }

  it "{T}, Sacrifice: puts a basic land onto the battlefield tapped" do
    hole = ResolvePermanent("Hobbit Hole", owner: p1)
    hole.untap!
    forest = Card("Forest", owner: p1)
    p1.library.add(forest)

    p1.activate_ability(ability: hole.activated_abilities.first)
    game.stack.resolve!
    game.tick!
    game.resolve_choice!(targets: [forest])

    expect(p1.graveyard.cards.map(&:name)).to include("Hobbit Hole")
    expect(forest.zone).to be_battlefield
    expect(p1.permanents.find { _1.name == "Forest" }).to be_tapped
  end

  it "Halflingcycling {4}: searches for a Halfling card" do
    card = Card("Hobbit Hole", owner: p1)
    p1.hand.add(card)
    halfling = Card("Belladonna Took", owner: p1)
    p1.library.add(halfling)
    p1.add_mana(colorless: 4)
    p1.cycle(card:) { _1.pay_mana(generic: { colorless: 4 }) }
    game.choices.last.resolve!(targets: [halfling])

    expect(card.zone).to be_graveyard
    expect(halfling.zone).to be_hand
  end
end
