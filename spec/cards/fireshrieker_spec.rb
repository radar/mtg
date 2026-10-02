# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Fireshrieker do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:fireshrieker) { ResolvePermanent("Fireshrieker", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gives the equipped creature double strike" do
    fireshrieker.attach_to!(bears)
    game.tick!

    expect(bears).to be_double_strike
    expect(other).not_to be_double_strike
  end

  it "equips for {2}" do
    p1.add_mana(red: 2)
    p1.activate_ability(ability: fireshrieker.activated_abilities.first) { _1.pay_mana(generic: { red: 2 }).targeting(bears) }
    game.stack.resolve!

    expect(fireshrieker.attached_to).to eq(bears)
  end
end
