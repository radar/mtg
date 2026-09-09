require "spec_helper"

RSpec.describe Magic::Cards::SwiftfootBoots do
  include_context "two player game"

  it "grants hexproof and haste to an equipped creature" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    equipment = ResolvePermanent("Swiftfoot Boots", owner: p1)
    p1.add_mana(generic: 1)
    p1.activate_ability(ability: equipment.activated_abilities.first) do |ability|
      ability.targeting(creature)
      ability.pay_mana(generic: { generic: 1 })
    end
    game.stack.resolve!
    game.tick!

    expect(creature).to be_hexproof
    expect(creature.has_keyword?(:haste)).to be(true)
  end
end