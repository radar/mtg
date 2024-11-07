require 'spec_helper'

RSpec.describe Magic::Cards::AngelicAscension do
  include_context "two player game"

  subject(:wood_elves) { Magic::Permanent.resolve(game: game, owner: p1, card: Card("Wood Elves")) }
  subject { add_to_library("Angelic Ascension", player: p1) }

  it "exiles the wood elves and creates a 4/4 white angel creature token with flying" do
    cast_and_resolve(card: subject, player: p1) do |action|
      action.targeting(wood_elves)
    end

    aggregate_failures do
      expect(wood_elves.card.zone).to be_exile
      expect(wood_elves.zone).to be_nil
    end

    expect(creatures.count).to eq(1)
    angel = creatures.first
    expect(angel.name).to eq("Angel")
    expect(angel.power).to eq(4)
    expect(angel.toughness).to eq(4)
    expect(angel.colors).to eq([:white])
    expect(angel.flying?).to eq(true)
  end
end
