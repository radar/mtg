require 'spec_helper'

RSpec.describe Magic::Cards::LightningBolt do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  let(:lightning_bolt) { described_class.new(game: game) }

  it "destroys the wood elves" do
    p1.add_mana(red: 3)
    action = cast_action(player: p1, card: lightning_bolt)
    action.pay_mana(red: 1)
    action.targeting(wood_elves)
    game.take_action(action)
    game.tick!
    expect(wood_elves).to be_dead
  end

  it "targets a player" do
    p2_starting_life = p2.life
    p1.add_mana(red: 3)
    action = cast_action(player: p1, card: lightning_bolt)
    action.pay_mana(red: 1)
    action.targeting(p2)
    game.take_action(action)
    game.tick!
    expect(p2.life).to eq(p2_starting_life - 3)
  end
end
