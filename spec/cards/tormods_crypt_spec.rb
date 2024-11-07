require 'spec_helper'

RSpec.describe Magic::Cards::TormodsCrypt do
  include_context "two player game"
  subject(:permanent) { ResolvePermanent("Tormod's Crypt") }

  let(:wood_elves) { Card("Wood Elves", owner: p2) }

  before do
    wood_elves.move_to_graveyard!
  end

  it "taps and sacrifices to exile a player's graveyard" do
    p1.activate_ability(ability: permanent.activated_abilities.first) do
      _1.targeting(p2)
    end

    game.stack.resolve!

    expect(p2.graveyard).to be_empty
    expect(wood_elves.zone).to be_exile
  end
end
