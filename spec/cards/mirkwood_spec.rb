# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Mirkwood do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:land) { ResolvePermanent("Mirkwood", owner: p1) }

  it "enters tapped" do
    p1.play_land(land: Card("Mirkwood", owner: p1))
    expect(p1.permanents.by_name("Mirkwood").last).to be_tapped
  end

  it "taps for black or green" do
    expect(land.activated_abilities.first.choices).to contain_exactly(:black, :green)
  end

  it "sacrifices to put two +1/+1 counters on a Bear" do
    land.untap!
    bear = ResolvePermanent("Large Bear", owner: p1)
    p1.add_mana(black: 2, green: 2)
    p1.activate_ability(ability: land.activated_abilities.last) { |a| a.pay_mana(generic: { black: 1, green: 1 }, black: 1, green: 1).targeting(bear) }
    game.stack.resolve!
    expect(bear.power).to eq(7)
    expect(p1.graveyard.cards.map(&:name)).to include("Mirkwood")
  end

  it "cannot target a non Bear, Spider or Wolf" do
    land.untap!
    human = ResolvePermanent("Lake Town Lookout", owner: p1)
    expect(land.activated_abilities.last.target_choices).not_to include(human)
  end
end
