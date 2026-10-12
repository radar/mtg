# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BearTrap do
  include_context "two player game"

  let!(:trap) { ResolvePermanent("Bear Trap", owner: p1) }
  let!(:target) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "has flash" do
    expect(Card("Bear Trap")).to be_flash
  end

  it "deals 3 damage to target creature, sacrificing itself" do
    p1.add_mana(colorless: 3)
    p1.activate_ability(ability: trap.activated_abilities.first) do |action|
      action.pay_mana(generic: { colorless: 3 })
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(p1.permanents).not_to include(trap)
  end
end
