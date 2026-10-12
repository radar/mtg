# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LakeTown do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:land) { ResolvePermanent("Lake Town", owner: p1) }

  it "enters tapped" do
    p1.play_land(land: Card("Lake Town", owner: p1))
    expect(p1.permanents.by_name("Lake-town").last).to be_tapped
  end

  it "taps for white or blue" do
    expect(land.activated_abilities.first.choices).to contain_exactly(:white, :blue)
  end

  it "sacrifices to put two +1/+1 counters on a Human" do
    land.untap!
    human = ResolvePermanent("Lakeshore Apothecary", owner: p1)
    p1.add_mana(white: 2, blue: 2)
    ability = land.activated_abilities.last
    p1.activate_ability(ability: ability) { |a| a.pay_mana(generic: { white: 1, blue: 1 }, white: 1, blue: 1).targeting(human) }
    game.stack.resolve!
    expect(human.power).to eq(3)
    expect(p1.graveyard.cards.map(&:name)).to include("Lake-town")
  end
end
