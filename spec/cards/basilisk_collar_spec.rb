# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BasiliskCollar do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:collar) { ResolvePermanent("Basilisk Collar", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gives the equipped creature deathtouch and lifelink" do
    collar.attach_to!(bears)
    game.tick!

    expect(bears).to be_deathtouch
    expect(bears).to be_lifelink
  end

  it "doesn't affect other creatures" do
    collar.attach_to!(bears)
    game.tick!

    expect(other).not_to be_deathtouch
  end

  it "equips for {2}" do
    p1.add_mana(green: 2)
    p1.activate_ability(ability: collar.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }).targeting(bears) }
    game.stack.resolve!

    expect(collar.attached_to).to eq(bears)
  end
end
