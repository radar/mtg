require "spec_helper"

RSpec.describe Magic::Cards::TearAsunder do
  include_context "two player game"

  it "exiles an artifact or enchantment" do
    target = ResolvePermanent("Mind Stone", owner: p2)
    spell = Card("Tear Asunder", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)
    p1.cast(card: spell) do |action|
      action.targeting(target)
      action.pay_mana(green: 1, generic: { green: 1 })
    end
    game.stack.resolve!

    expect(target.card.zone).to be_exile
  end
end