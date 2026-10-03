# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MidnightReaper do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:reaper) { ResolvePermanent("Midnight Reaper", owner: p1) }

  it "is a 3/2 Zombie Knight" do
    expect([reaper.power, reaper.toughness]).to eq([3, 2])
    expect(reaper.type?("Knight")).to eq(true)
  end

  it "deals 1 damage to you and draws a card when a nontoken creature you control dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    expect { bears.destroy!; game.settle! }.to change { p1.hand.count }.by(1).and change { p1.life }.by(-1)
  end

  it "triggers on its own death" do
    expect { reaper.destroy!; game.settle! }.to change { p1.hand.count }.by(1).and change { p1.life }.by(-1)
  end

  it "does not trigger for a token" do
    token = Magic::Permanent.resolve(game:, owner: p1, card: ResolvePermanent("Grizzly Bears", owner: p2).copiable_card, token: true, copy: true, cast: false)

    expect { token.destroy!; game.settle! }.not_to(change { [p1.hand.count, p1.life] })
  end

  it "does not trigger for an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    expect { theirs.destroy!; game.settle! }.not_to(change { [p1.hand.count, p1.life] })
  end

  it "draws a card per creature when several die at once" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect { p1.creatures.select { _1.name == "Grizzly Bears" }.each(&:destroy!); game.settle! }
      .to change { p1.hand.count }.by(2).and change { p1.life }.by(-2)
  end
end
