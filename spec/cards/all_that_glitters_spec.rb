require "spec_helper"

RSpec.describe Magic::Cards::AllThatGlitters do
  include_context "two player game"

  it "boosts the enchanted creature for each artifact and enchantment" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    aura = Card("All That Glitters", owner: p1)
    p1.hand.add(aura)
    p1.add_mana(white: 2)
    p1.cast(card: aura) do |action|
      action.targeting(creature)
      action.pay_mana(white: 1, generic: { white: 1 })
    end
    game.stack.resolve!
    game.tick!

    expect(creature.power).to eq(3)
    expect(creature.toughness).to eq(3)
  end
end