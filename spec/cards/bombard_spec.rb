require 'spec_helper'

RSpec.describe Magic::Cards::Bombard do
  include_context "two player game"

  let(:wood_elves) { Card("Wood Elves", controller: p2) }

  let(:bombard) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(wood_elves)
  end

  it "destroys the wood elves" do
    p2_starting_life = p2.life
    p1.add_mana(red: 3)
    action = Magic::Actions::Cast.new(player: p1, card: bombard)
    action.pay_mana(generic: { red: 2 }, red: 1)
    action.targeting(wood_elves)
    game.take_action(action)
    game.tick!
    expect(wood_elves.zone).to be_graveyard
  end


end
