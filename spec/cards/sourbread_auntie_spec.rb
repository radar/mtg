require "spec_helper"

RSpec.describe Magic::Cards::SourbreadAuntie do
  include_context "two player game"

  def goblins = game.battlefield.creatures.by_name("Goblin")

  it "is a 4/3" do
    auntie = ResolvePermanent("Sourbread Auntie", owner: p1)
    game.skip_choice!

    expect([auntie.power, auntie.toughness]).to eq([4, 3])
  end

  it "may blight 2 when it enters; if you do, creates two 1/1 black and red Goblin tokens" do
    auntie = ResolvePermanent("Sourbread Auntie", owner: p1)
    game.resolve_choice!
    game.resolve_choice!(target: auntie)
    game.settle!

    expect(auntie.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
    expect(goblins.count).to eq(2)
    expect(goblins).to all(have_attributes(power: 1, toughness: 1, colors: contain_exactly(:black, :red)))
  end

  it "creates no tokens when you decline" do
    ResolvePermanent("Sourbread Auntie", owner: p1)
    game.skip_choice!

    expect(goblins).to be_empty
  end
end
