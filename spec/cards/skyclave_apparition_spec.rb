# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkyclaveApparition do
  include_context "two player game"

  def illusions(player) = player.creatures.select { _1.name == "Illusion" && _1.token? }

  it "exiles a nonland, nontoken permanent with mana value 4 or less that you don't control" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Skyclave Apparition", owner: p1)
    game.resolve_choice!(target: bears)

    expect(bears.card.zone).to be_exile
  end

  it "asks which one when there is a choice, and offers only legal ones" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ring = ResolvePermanent("Sol Ring", owner: p2)
    ResolvePermanent("Forest", owner: p2)
    ResolvePermanent("Baneslayer Angel", owner: p2) # mana value 5
    mine = ResolvePermanent("Llanowar Elves", owner: p1)
    ResolvePermanent("Skyclave Apparition", owner: p1)

    choice = game.choices.last
    expect(choice.choices).to contain_exactly(bears, ring)
    expect(choice.choices).not_to include(mine)
    game.resolve_choice!(target: ring)

    expect(ring.card.zone).to be_exile
  end

  it "may exile nothing" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Sol Ring", owner: p2)
    ResolvePermanent("Skyclave Apparition", owner: p1)
    game.skip_choice!

    expect(p2.permanents).to include(bears)
  end

  it "gives the exiled card's owner an X/X blue Illusion when it leaves the battlefield" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    apparition = ResolvePermanent("Skyclave Apparition", owner: p1)
    game.resolve_choice!(target: bears)

    apparition.destroy!
    game.settle!

    expect(illusions(p2).count).to eq(1)
    expect([illusions(p2).first.power, illusions(p2).first.toughness]).to eq([2, 2])
    expect(illusions(p2).first.colors).to eq([:blue])
    expect(illusions(p1)).to be_empty
  end

  it "makes no token when nothing was exiled" do
    apparition = ResolvePermanent("Skyclave Apparition", owner: p1)

    apparition.destroy!
    game.settle!

    expect(illusions(p1) + illusions(p2)).to be_empty
  end
end
