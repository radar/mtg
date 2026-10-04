# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DriverOfTheDead do
  include_context "two player game"

  let(:cheap) { Card("Grizzly Bears", owner: p1) }
  let(:other_cheap) { Card("Diregraf Ghoul", owner: p1) }
  let(:expensive) { Card("Elvish Regrower", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }

  it "is a 3/2 Vampire" do
    driver = ResolvePermanent("Driver Of The Dead", owner: p1)

    expect([driver.power, driver.toughness]).to eq([3, 2])
  end

  it "returns a creature card with mana value 2 or less from your graveyard to the battlefield when it dies" do
    p1.graveyard.add(cheap)
    p1.graveyard.add(other_cheap)
    driver = ResolvePermanent("Driver Of The Dead", owner: p1)
    driver.destroy!
    game.settle!
    game.resolve_choice!(target: cheap)

    expect(p1.creatures.map(&:card)).to contain_exactly(cheap)
    expect(other_cheap.zone).to be_graveyard
  end

  it "only offers creature cards with mana value 2 or less" do
    p1.graveyard.add(cheap)
    p1.graveyard.add(expensive)
    p1.graveyard.add(bolt)
    driver = ResolvePermanent("Driver Of The Dead", owner: p1)
    driver.destroy!
    game.settle!

    # one legal target is chosen for you
    expect(p1.creatures.map(&:card)).to contain_exactly(cheap)
    expect(expensive.zone).to be_graveyard
    expect(bolt.zone).to be_graveyard
  end

  it "can't return a creature card from an opponent's graveyard" do
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    driver = ResolvePermanent("Driver Of The Dead", owner: p1)
    driver.destroy!
    game.settle!

    expect(p1.creatures).to be_empty
    expect(p2.creatures).to be_empty
  end
end
