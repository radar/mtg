require 'spec_helper'

RSpec.describe Magic::Cards::PathOfPeace do
  include_context "two player game"

  let!(:loxodon_wayfarer) { ResolvePermanent("Loxodon Wayfarer", controller: p2) }

  let(:card) { described_class.new(game: game) }

  it "destroys Loxodon Wayfarer" do
    p2_starting_life = p2.life
    action = cast_action(card: card, player: p1).targeting(loxodon_wayfarer)
    add_to_stack_and_resolve(action)
    expect(loxodon_wayfarer.zone).to be_graveyard
    expect(p2.life).to eq(p2_starting_life + 4)
  end
end
