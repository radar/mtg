require "spec_helper"

RSpec.describe Magic::Cards::GhoulishImpetus do
  include_context "two player game"

  it "grants +1/+1 and deathtouch to an enchanted creature" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    aura = Card("Ghoulish Impetus", owner: p1)
    p1.hand.add(aura)
    p1.add_mana(black: 3)
    p1.cast(card: aura) do |action|
      action.targeting(creature)
      action.pay_mana(black: 1, generic: { black: 2 })
    end
    game.stack.resolve!
    game.tick!

    expect(creature.power).to eq(3)
    expect(creature).to be_deathtouch
  end
end