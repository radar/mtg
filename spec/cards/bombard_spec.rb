require 'spec_helper'

RSpec.describe Magic::Cards::Bombard do
  include_context "two player game"

  let(:wood_elves) { Card("Wood Elves", controller: p2) }

  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(wood_elves)
  end

  it "destroys the wood elves" do
    p2_starting_life = p2.life
    p1.add_mana(red: 3)
    cast_action = p1.prepare_to_cast(card).targeting(wood_elves)
    cast_action.pay(generic: { red: 2 }, red: 1)
    cast_action.perform!
    game.tick!
    expect(wood_elves.zone).to be_graveyard
  end


end
