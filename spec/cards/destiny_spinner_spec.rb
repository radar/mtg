require "spec_helper"

RSpec.describe Magic::Cards::DestinySpinner do
  include_context "two player game"

  it "stops your creature and enchantment spells being countered, but not other spells or an opponent's" do
    ResolvePermanent("Destiny Spinner", owner: p1)
    creature = Card("Grizzly Bears", owner: p1)
    enchantment = Card("Phyrexian Arena", owner: p1)
    instant = Card("Shock", owner: p1)
    theirs = Card("Grizzly Bears", owner: p2)
    [creature, enchantment, instant].each { |card| p1.hand.add(card) }
    p2.hand.add(theirs)

    expect([creature, enchantment].map(&:can_be_countered?)).to eq([false, false])
    expect([instant, theirs].map(&:can_be_countered?)).to eq([true, true])
  end

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