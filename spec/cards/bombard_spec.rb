require 'spec_helper'

RSpec.describe Magic::Cards::Bombard do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:alpine_watchdog) { ResolvePermanent("Alpine Watchdog", owner: p2) }

  let(:bombard) { Card("Bombard") }

  before do
    p1.hand.add(bombard)
  end

  it "destroys the wood elves" do
    p1.add_mana(red: 3)
    action = cast_action(player: p1, card: bombard)
    expect(action.target_choices).to include(wood_elves)
    expect(action.target_choices).to include(alpine_watchdog)
    action.targeting(wood_elves)
    action.auto_pay_mana
    game.take_action(action)
    game.stack.resolve!
    expect(wood_elves.damage).to eq(4)
    expect(wood_elves).to be_dead
    expect(alpine_watchdog).to be_alive
  end
end
