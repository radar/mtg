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
end