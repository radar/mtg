require 'spec_helper'

RSpec.describe Magic::Cards::AngelicAscension do
  include_context "two player game"

  subject(:wood_elves) { Magic::Permanent.resolve(game: game, controller: p1, card: Card("Wood Elves")) }
  subject { add_to_library("Angelic Ascension", player: p1) }

  it "exiles the wood elves and creates a 4/4 white angel creature token with flying" do
    action = cast_action(card: subject, player: p1, targeting: wood_elves)
    add_to_stack_and_resolve(action)

    expect(wood_elves.card.zone).to be_exile

    expect(game.battlefield.creatures.count).to eq(1)
    angel = game.battlefield.creatures.first
    expect(angel.name).to eq("Angel")
    expect(angel.power).to eq(4)
    expect(angel.toughness).to eq(4)
    expect(angel.colors).to eq([:white])
    expect(angel.flying?).to eq(true)
  end
end
