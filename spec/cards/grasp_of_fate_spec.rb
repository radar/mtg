require "spec_helper"

RSpec.describe Magic::Cards::GraspOfFate do
  include_context "two player game"

  it "exiles an opponent's nonland permanent until it leaves" do
    target = ResolvePermanent("Grizzly Bears", owner: p2)
    # The only legal target, so the choice resolves itself.
    grasp = ResolvePermanent("Grasp of Fate", owner: p1)

    expect(target.card.zone).to be_exile
    grasp.destroy!
    game.settle!

    expect(target.card.zone).to be_battlefield
  end

  it "asks which permanent when there is a choice" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    elves = ResolvePermanent("Wood Elves", owner: p2)
    ResolvePermanent("Grasp of Fate", owner: p1)

    expect(game.choices.last.choices).to contain_exactly(bears, elves)
    game.resolve_choice!(target: elves)

    expect(elves.card.zone).to be_exile
  end

  it "cannot target a permanent with hexproof, so another is the only choice" do
    hexproof = ResolvePermanent("Grizzly Bears", owner: p2)
    hexproof.grant_keyword(Magic::Cards::Keywords::HEXPROOF)
    other = ResolvePermanent("Wood Elves", owner: p2)
    game.tick!
    ResolvePermanent("Grasp of Fate", owner: p1)

    expect(other.card.zone).to be_exile
    expect(game.battlefield.permanents).to include(hexproof)
  end

  it "returns exiled Equipment to the battlefield unattached" do
    sword = ResolvePermanent("Swiftfoot Boots", owner: p2)
    grasp = ResolvePermanent("Grasp of Fate", owner: p1)
    expect(sword.card.zone).to be_exile

    expect { grasp.destroy!; game.settle! }.not_to raise_error
    expect(p2.permanents.by_name("Swiftfoot Boots").count).to eq(1)
  end

  it "exiles a token for good" do
    token = Magic::Cards::SigilOfTheEmptyThrone::AngelToken.new(game: game, owner: p2).resolve!
    grasp = ResolvePermanent("Grasp of Fate", owner: p1)

    expect(game.battlefield.permanents).not_to include(token)
    grasp.destroy!
    game.settle!

    expect(game.battlefield.permanents.map(&:name)).not_to include("Angel")
  end
end
