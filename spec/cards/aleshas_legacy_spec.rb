# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AleshasLegacy do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:legacy) { Card("Alesha's Legacy", owner: p1) }

  before do
    p1.hand.add(legacy)
    p1.add_mana(black: 2)
  end

  def cast_on(target)
    p1.cast(card: legacy) { |a| a.pay_mana(black: 1, generic: { black: 1 }).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "gives a creature you control deathtouch and indestructible" do
    cast_on(bears)
    expect(bears.has_keyword?(Magic::Cards::Keywords::DEATHTOUCH)).to eq(true)
    expect(bears.has_keyword?(Magic::Cards::Keywords::INDESTRUCTIBLE)).to eq(true)
  end

  it "makes the creature survive lethal destruction" do
    cast_on(bears)
    bears.destroy!
    expect(bears.zone).to eq(game.battlefield)
  end

  it "cannot target an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    expect(legacy.target_choices).to include(bears)
    expect(legacy.target_choices).not_to include(theirs)
  end
end
