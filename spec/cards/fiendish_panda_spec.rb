# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FiendishPanda do
  include_context "two player game"

  let(:ghoul) { Card("Diregraf Ghoul", owner: p1) }
  let(:regrower) { Card("Elvish Regrower", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }

  it "is a 3/2 Bear Demon" do
    panda = ResolvePermanent("Fiendish Panda", owner: p1)

    expect([panda.power, panda.toughness]).to eq([3, 2])
  end

  it "gets a +1/+1 counter whenever you gain life" do
    panda = ResolvePermanent("Fiendish Panda", owner: p1)
    p1.gain_life(2)
    game.settle!

    expect(panda.power).to eq(4)
  end

  it "returns a non-Bear creature card with mana value up to its power when it dies" do
    p1.graveyard.add(regrower) # mana value 4
    p1.graveyard.add(ghoul)
    panda = ResolvePermanent("Fiendish Panda", owner: p1)
    p1.gain_life(1)
    game.settle!
    panda.destroy!
    game.settle!

    # power 4 at death: mana value 4 is allowed, so both are legal
    game.resolve_choice!(target: regrower)
    expect(p1.creatures.map(&:card)).to contain_exactly(regrower)
  end

  it "can't return a card whose mana value is greater than its power" do
    p1.graveyard.add(regrower) # mana value 4, panda power is 3
    p1.graveyard.add(ghoul)
    panda = ResolvePermanent("Fiendish Panda", owner: p1)
    panda.destroy!
    game.settle!

    expect(p1.creatures.map(&:card)).to contain_exactly(ghoul)
    expect(regrower.zone).to be_graveyard
  end

  it "can't return a Bear, a noncreature card or the Panda itself" do
    bear = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(bear)
    p1.graveyard.add(bolt)
    panda = ResolvePermanent("Fiendish Panda", owner: p1)
    panda.destroy!
    game.settle!

    expect(p1.creatures).to be_empty
    expect(bear.zone).to be_graveyard
    expect(panda.card.zone).to be_graveyard
  end
end
