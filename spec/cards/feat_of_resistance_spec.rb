require 'spec_helper'

RSpec.describe Magic::Cards::FeatOfResistance do
  include_context "two player game"

  subject { Card("Feat Of Resistance") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  let(:green_card) { double(Magic::Card, colors: [:green] )}

  before do
    game.battlefield.add(wood_elves)
  end

  it "adds a +1,+1 counter and protection from green to wood elves" do
    p1.add_mana(white: 2)
    action = cast_action(card: subject, player: p1).targeting(wood_elves)
    action.pay_mana(white: 1, generic: { white: 1})
    game.take_action(action)
    game.tick!

    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Color)
    game.resolve_choice!(color: :green)
    expect(wood_elves.protected_from?(green_card)).to eq(true)
  end
end
