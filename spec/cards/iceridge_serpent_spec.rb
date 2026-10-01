# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IceridgeSerpent do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  # With a single legal target the engine targets it automatically.
  let!(:serpent) { ResolvePermanent("Iceridge Serpent", owner: p1) }

  it "is a 3/3" do
    expect([serpent.power, serpent.toughness]).to eq([3, 3])
  end

  it "returns the opponent's creature to its owner's hand, leaving its controller's creatures alone" do
    expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
    expect(game.battlefield.creatures).not_to include(bears)
    expect(game.battlefield.creatures).to include(mine)
  end

  it "lets you choose when there are several opposing creatures" do
    a = ResolvePermanent("Wood Elves", owner: p2)
    b = ResolvePermanent("Wood Elves", owner: p2)
    ResolvePermanent("Iceridge Serpent", owner: p1)
    expect(game.choices.last.choices).to contain_exactly(a, b)
    game.resolve_choice!(target: a)
    expect(game.battlefield.creatures).not_to include(a)
    expect(game.battlefield.creatures).to include(b)
  end
end
