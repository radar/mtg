# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HorrificAssault do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mine) { ResolvePermanent("Nettle Guard", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def assault(*targets)
    p1.add_mana(green: 1)
    p1.cast(card: Card("Horrific Assault", owner: p1)) do |action|
      action.targeting(*targets)
      action.auto_pay_mana
    end
    game.settle!
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "has your creature deal damage equal to its power to a creature you don't control" do
    assault(mine, theirs)

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(mine.damage).to eq(0)
  end

  it "can target a planeswalker you don't control" do
    walker = ResolvePermanent("Grist, The Hunger Tide", owner: p2)
    assault(mine, walker)

    expect(walker.loyalty).to eq(3 - mine.power)
  end

  it "does not offer your own creatures as the second target" do
    expect { assault(mine, mine) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "does not accept an opponent's creature as the creature you control" do
    expect { assault(theirs, theirs) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "gains 3 life if you control an Eldrazi" do
    ResolvePermanent("Territory Culler", owner: p1)
    expect { assault(mine, theirs) }.to change { p1.life }.by(3)
  end

  it "gains 3 life if you control a noncreature Eldrazi permanent" do
    ResolvePermanent("Idol Of False Gods", owner: p1)
    expect { assault(mine, theirs) }.to change { p1.life }.by(3)
  end

  it "gains no life without an Eldrazi" do
    expect { assault(mine, theirs) }.not_to(change { p1.life })
  end
end
