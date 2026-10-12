require "spec_helper"

RSpec.describe Magic::Cards::PathToExile do
  include_context "two player game"

  it "exiles a target creature" do
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    spell = Card("Path To Exile", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(white: 1)
    p1.cast(card: spell) do |action|
      action.targeting(creature)
      action.pay_mana(white: 1)
    end
    game.stack.resolve!

    expect(creature.card.zone).to be_exile
  end

  it "lets the controller of an exiled token search for a basic land" do
    p2.library.add(Card("Forest", owner: p2))
    token = ResolvePermanent("Bastion of Remembrance", owner: p2)
    token = p2.creatures.find(&:token?) || token
    spell = Card("Path To Exile", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(white: 1)
    p1.cast(card: spell) do |action|
      action.targeting(token)
      action.pay_mana(white: 1)
    end

    expect { game.stack.resolve! }.not_to raise_error
    expect(game.choices.last.controller).to eq(p2)
  end
end