require "spec_helper"

RSpec.describe Magic::Cards::EtherealArmor do
  include_context "two player game"

  it "grants first strike and scales with enchantments" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    aura = Card("Ethereal Armor", owner: p1)
    p1.hand.add(aura)
    p1.add_mana(white: 1)
    p1.cast(card: aura) do |action|
      action.targeting(creature)
      action.pay_mana(white: 1)
    end
    game.stack.resolve!
    game.tick!

    expect(creature.power).to eq(3)
    expect(creature).to be_first_strike
  end
end