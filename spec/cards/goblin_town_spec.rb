# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoblinTown do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:land) { ResolvePermanent("Goblin Town", owner: p1) }

  it "enters tapped" do
    p1.play_land(land: Card("Goblin Town", owner: p1))
    expect(p1.permanents.by_name("Goblin-town").last).to be_tapped
  end

  it "taps for black or red" do
    expect(land.activated_abilities.first.choices).to contain_exactly(:black, :red)
  end

  it "sacrifices to put two +1/+1 counters on a Goblin" do
    land.untap!
    goblin = ResolvePermanent("Goblin Town Flunkies", owner: p1)
    p1.add_mana(black: 2, red: 2)
    p1.activate_ability(ability: land.activated_abilities.last) { |a| a.pay_mana(generic: { black: 1, red: 1 }, black: 1, red: 1).targeting(goblin) }
    game.stack.resolve!
    expect(goblin.power).to eq(3)
    expect(p1.graveyard.cards.map(&:name)).to include("Goblin-town")
  end

  it "cannot target a creature that is not a Goblin or Orc" do
    land.untap!
    human = ResolvePermanent("Lake Town Lookout", owner: p1)
    expect(land.activated_abilities.last.target_choices).not_to include(human)
  end
end
