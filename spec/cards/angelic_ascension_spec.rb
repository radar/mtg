require 'spec_helper'

RSpec.describe Magic::Cards::AngelicAscension do
  include_context "two player game"

  let(:wood_elves) { Card("Wood Elves") }

  subject { Card("Angelic Ascension") }

  before do
    game.battlefield.add(wood_elves)
  end

  it "exiles the wood elves and creates a 4/4 white angel creature token with flying" do
    subject.cast!
    game.stack.resolve!
    expect(wood_elves.zone).to be_exile

    expect(game.battlefield.creatures.count).to eq(1)
    angel = game.battlefield.creatures.first
    expect(angel.name).to eq("Angel")
    expect(angel.power).to eq(4)
    expect(angel.toughness).to eq(4)
    expect(angel.colors).to eq([:white])
    expect(angel.flying?).to eq(true)
  end
end
