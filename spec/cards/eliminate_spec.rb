require 'spec_helper'

RSpec.describe Magic::Cards::Eliminate do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p2) }

  let(:eliminate) { described_class.new(game: game, controller: p1) }

  it "destroys the wood elves" do
    p2_starting_life = p2.life
    p1.add_mana(black: 2)
    action = cast_action(player: p1, card: eliminate)
    action.pay_mana(generic: { black: 1 }, black: 1)
    action.targeting(wood_elves)
    game.take_action(action)
    game.tick!
    expect(wood_elves.zone).to be_graveyard
  end


end
