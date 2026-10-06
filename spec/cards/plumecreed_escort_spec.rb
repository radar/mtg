# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PlumecreedEscort do
  include_context "two player game"

  it "is a 2/1 flash flyer" do
    escort = ResolvePermanent("Plumecreed Escort", owner: p1)

    expect([escort.power, escort.toughness]).to eq([2, 1])
    expect(escort).to be_flying
    expect(Card("Plumecreed Escort", owner: p1).keywords).to include(Magic::Cards::Keywords::FLASH)
  end

  it "gives a creature you control hexproof until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Plumecreed Escort", owner: p1)

    expect(game.choices.last).to be_a(described_class::HexproofChoice)
    game.resolve_choice!(target: bears)
    game.tick!

    expect(bears).to have_keyword(:hexproof)
  end

  it "does not offer an opponent's creature" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Plumecreed Escort", owner: p1)

    expect(game.choices.last.choices).to contain_exactly(mine, p1.creatures.find { _1.name == "Plumecreed Escort" })
  end
end
