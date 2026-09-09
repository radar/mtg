require "spec_helper"

RSpec.describe Magic::Cards::DestinySpinner do
  include_context "two player game"

  it "can animate a land" do
    spinner = ResolvePermanent("Destiny Spinner", owner: p1)
    land = ResolvePermanent("Forest", owner: p1)
    p1.add_mana(green: 4)
    p1.activate_ability(ability: spinner.activated_abilities.first) do |ability|
      ability.targeting(land)
      ability.pay_mana(green: 1, generic: { green: 3 })
    end
    game.stack.resolve!
    game.tick!

    expect(land).to be_creature
    expect(land).to be_trample
  end
end