require "spec_helper"

RSpec.describe Magic::Cards::ElderAuntie do
  include_context "two player game"

  it "is a 2/2 Goblin Warlock that creates a 1/1 black and red Goblin token when it enters" do
    auntie = ResolvePermanent("Elder Auntie", owner: p1)
    goblin = game.battlefield.creatures.by_name("Goblin").first

    expect([auntie.power, auntie.toughness]).to eq([2, 2])
    expect([goblin.power, goblin.toughness]).to eq([1, 1])
    expect(goblin.colors).to contain_exactly(:black, :red)
    expect(goblin).to be_token
  end
end
