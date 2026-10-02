# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExtravagantReplication do
  include_context "two player game"

  let!(:replication) { ResolvePermanent("Extravagant Replication", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:cub) { ResolvePermanent("Bear Cub", owner: p1) }

  it "creates a token copy of another nonland permanent you control at the beginning of your upkeep" do
    go_to_main_phase!
    game.resolve_choice!(target: bears)
    game.settle!

    expect(p1.creatures.select { _1.name == "Grizzly Bears" }.count).to eq(2)
    expect(p1.creatures.select { _1.name == "Grizzly Bears" }.count(&:token?)).to eq(1)
  end

  it "can't copy itself" do
    go_to_main_phase!

    expect(game.choices.last.choices).not_to include(replication)
  end

  it "doesn't trigger on an opponent's upkeep" do
    go_to_main_phase!
    game.resolve_choice!(target: bears)
    game.settle!
    go_to_main_phase_for!(p2)

    expect(game.choices).to be_empty
  end
end
