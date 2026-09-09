require "spec_helper"

RSpec.describe Magic::Cards::ChaosWarp do
  include_context "two player game"

  it "shuffles the target into its owner's library" do
    target = ResolvePermanent("Grizzly Bears", owner: p2)
    spell = Card("Chaos Warp", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(red: 3)
    p1.cast(card: spell) do |action|
      action.targeting(target)
      action.pay_mana(red: 1, generic: { red: 2 })
    end
    game.stack.resolve!

    expect(p2.library.by_name("Grizzly Bears").count).to eq(1)
  end
end