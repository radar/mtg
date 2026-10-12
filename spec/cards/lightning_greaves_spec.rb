# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LightningGreaves do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:greaves) { ResolvePermanent("Lightning Greaves", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def equip!
    p1.activate_ability(ability: greaves.activated_abilities.first) { _1.targeting(bears) }
    game.stack.resolve!
    game.tick!
  end

  it "equips for {0}" do
    equip!

    expect(greaves.attached_to).to eq(bears)
  end

  it "gives the equipped creature haste and shroud" do
    equip!

    expect(bears).to have_keyword(:haste)
    expect(bears).to have_keyword(:shroud)
  end

  it "makes the creature untargetable" do
    equip!

    expect(bears.can_be_targeted_by?(Card("Lightning Bolt", owner: p2), controller: p2)).to be(false)
  end

  it "gives nothing to other creatures" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    equip!

    expect(other).not_to have_keyword(:shroud)
  end
end
