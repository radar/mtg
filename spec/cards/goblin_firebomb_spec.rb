# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoblinFirebomb do
  include_context "two player game"

  let!(:firebomb) { ResolvePermanent("Goblin Firebomb", owner: p1) }
  let!(:anthem) { ResolvePermanent("Anthem Of Champions", owner: p2) }

  it "sacrifices itself for {7} to destroy target permanent" do
    p1.add_mana(red: 7)
    p1.activate_ability(ability: firebomb.activated_abilities.first) { _1.pay_mana(generic: { red: 7 }).targeting(anthem) }
    game.stack.resolve!
    game.tick!

    expect(firebomb.card.zone).to be_graveyard
    expect(anthem.card.zone).to be_graveyard
  end
end
