require 'spec_helper'

RSpec.describe Magic::Cards::FeatOfResistance do
  include_context "two player game"

  subject { Card("Feat Of Resistance", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p1) }

  let(:green_card) { double(Magic::Card, colors: [:green] )}

  before do
    game.battlefield.add(wood_elves)
  end

  it "adds a +1,+1 counter and protection from green to wood elves" do
    game.stack.targeted_cast(subject, targeting: wood_elves)

    game.stack.resolve!
    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Color)
    choice.choose(:green)
    expect(wood_elves.protected_from?(green_card)).to eq(true)
  end
end
