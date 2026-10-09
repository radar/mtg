# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IronHills do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:land) { ResolvePermanent("Iron Hills", owner: p1) }
  it "enters tapped" do
    p1.play_land(land: Card("Iron Hills", owner: p1))
    expect(p1.permanents.by_name("Iron Hills").last).to be_tapped
  end

  it "sacrifices to put two +1/+1 counters on a Dwarf" do
    land.untap!
    dwarf = ResolvePermanent("Iron Hills Stalwart", owner: p1)
    p1.add_mana(red: 2, white: 2)
    p1.activate_ability(ability: land.activated_abilities.last) { |a| a.pay_mana(generic: { red: 1, white: 1 }, red: 1, white: 1).targeting(dwarf) }
    game.stack.resolve!
    expect(dwarf.power).to eq(6)
    expect(p1.graveyard.cards.map(&:name)).to include("Iron Hills")
  end
end
