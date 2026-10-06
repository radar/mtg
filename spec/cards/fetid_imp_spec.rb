# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FetidImp do
  include_context "two player game"

  let!(:imp) { ResolvePermanent("Fetid Imp", owner: p1) }

  it "is a 1/2 flying Imp" do
    expect([imp.power, imp.toughness]).to eq([1, 2])
    expect(imp).to be_flying
  end

  it "gains deathtouch until end of turn for {B}" do
    expect(imp).not_to be_deathtouch

    p1.add_mana(black: 1)
    p1.activate_ability(ability: imp.activated_abilities.first) { _1.pay_mana(black: 1) }
    game.stack.resolve!
    game.tick!
    expect(imp).to be_deathtouch

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(imp).not_to be_deathtouch
  end
end
