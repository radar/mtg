require 'spec_helper'

RSpec.describe Magic::Cards::Bombard do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:alpine_watchdog) { ResolvePermanent("Alpine Watchdog", owner: p2) }

  let(:bombard) { Card("Bombard") }

  it "destroys the wood elves" do
    p2_starting_life = p2.life
    p1.add_mana(red: 3)
    action = cast_action(player: p1, card: bombard)
    action.pay_mana(generic: { red: 2 }, red: 1)
    expect(action.target_choices).to include(wood_elves)
    expect(action.target_choices).to include(alpine_watchdog)
    action.targeting(wood_elves)
    game.take_action(action)
    game.tick!
    expect(wood_elves.damage).to eq(4)
    expect(wood_elves).to be_dead
    expect(alpine_watchdog).to be_alive
  end
end
