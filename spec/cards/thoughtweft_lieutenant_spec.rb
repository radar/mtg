require "spec_helper"

RSpec.describe Magic::Cards::ThoughtweftLieutenant do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:lieutenant) { ResolvePermanent("Thoughtweft Lieutenant", owner: p1) }

  it "is a 2/2" do
    expect([lieutenant.power, lieutenant.toughness]).to eq([2, 2])
  end

  it "gives a creature you control +1/+1 and trample when it enters" do
    game.resolve_choice!(target: bears)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears).to be_trample
  end

  it "triggers again when another Kithkin enters under your control" do
    game.resolve_choice!(target: bears)
    ResolvePermanent("Thoughtweft Lieutenant", owner: p1)

    expect(game.choices.map(&:class).uniq.size).to eq(1)
    game.resolve_choice!(target: lieutenant)
    game.tick!
    expect([lieutenant.power, lieutenant.toughness]).to eq([3, 3])
  end

  it "doesn't trigger for other creatures or an opponent's Kithkin" do
    game.resolve_choice!(target: bears)
    ResolvePermanent("Wood Elves", owner: p1)
    ResolvePermanent("Thoughtweft Lieutenant", owner: p2)

    expect(game.choices.select { _1.actor == lieutenant }).to be_empty
  end
end
