# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UndeadSprinter do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:sprinter) { Card("Undead Sprinter", owner: p1) }

  def cast_from_graveyard
    p1.add_mana(black: 1, red: 1)
    p1.cast(card: sprinter) { |a| a.pay_mana(black: 1, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/2 Zombie with trample and haste" do
    permanent = ResolvePermanent("Undead Sprinter", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 2])
    expect(permanent).to have_keyword(Magic::Cards::Keywords::TRAMPLE)
    expect(permanent).to have_keyword(Magic::Cards::Keywords::HASTE)
  end

  context "in the graveyard" do
    before { p1.graveyard.add(sprinter) }

    it "can't be cast if no creature died this turn" do
      expect { cast_from_graveyard }.to raise_error(Magic::IllegalAction)
      expect(sprinter.zone).to be_graveyard
    end

    it "can't be cast if only a Zombie died this turn" do
      ResolvePermanent("Walking Corpse", owner: p2).destroy!
      game.settle!

      expect { cast_from_graveyard }.to raise_error(Magic::IllegalAction)
    end

    it "can be cast after a non-Zombie creature died, entering with a +1/+1 counter" do
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      game.settle!
      cast_from_graveyard

      expect(sprinter.zone).to be_battlefield
      permanent = p1.creatures.find { _1.name == "Undead Sprinter" }
      expect([permanent.power, permanent.toughness]).to eq([3, 3])
    end
  end

  it "has no counter when cast from hand" do
    p1.hand.add(sprinter)
    cast_from_graveyard

    permanent = p1.creatures.find { _1.name == "Undead Sprinter" }
    expect([permanent.power, permanent.toughness]).to eq([2, 2])
  end
end
