# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BattleRattleShaman do
  include_context "two player game"

  let!(:shaman) { ResolvePermanent("Battle-Rattle Shaman", owner: p1) }
  # With a single legal target the choice resolves itself, so there are always two creatures.
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def begin_combat(player)
    game.notify!(Magic::Events::BeginningOfCombat.new(active_player: player))
    game.settle!
  end

  it "is a 2/2 Goblin Shaman" do
    expect([shaman.power, shaman.toughness]).to eq([2, 2])
  end

  it "may give target creature +2/+0 at the beginning of combat on your turn" do
    begin_combat(p1)
    game.resolve_choice!(target: bears)
    game.tick!

    expect(bears.power).to eq(4)
  end

  it "may decline" do
    begin_combat(p1)
    game.skip_choice!
    game.tick!

    expect(shaman.power).to eq(2)
  end

  it "doesn't trigger on an opponent's turn" do
    begin_combat(p2)

    expect(game.choices).to be_empty
  end
end
