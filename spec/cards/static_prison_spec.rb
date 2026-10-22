# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StaticPrison do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_rival) { ResolvePermanent("Bear Cub", owner: p2) }
  let!(:rival_land) { ResolvePermanent("Forest", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  let!(:prison) { ResolvePermanent("Static Prison", owner: p1) }

  def exile_rival
    game.resolve_choice!(target: rival)
    game.settle!
  end

  it "can target only nonland permanents an opponent controls" do
    targets = game.choices.first.choices
    expect(targets).to include(rival, other_rival)
    expect(targets).not_to include(mine, rival_land)
  end

  it "exiles the target until it leaves the battlefield, and gives you two energy" do
    expect(p1.energy).to eq(0)
    exile_rival

    expect(game.exile.cards).to include(rival.card)
    expect(p1.energy).to eq(2)
  end

  it "returns the exiled permanent when it leaves the battlefield" do
    exile_rival
    prison.destroy!
    game.settle!

    expect(game.exile.cards).not_to include(rival.card)
    expect(p2.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "still gives you two energy with no legal target" do
    p2.creatures.each(&:destroy!)
    game.skip_choice! if game.choices.any?
    game.settle!
    p1.pay_energy!(p1.energy)

    ResolvePermanent("Static Prison", owner: p1)
    game.settle!

    expect(p1.energy).to eq(2)
  end

  context "at the beginning of your first main phase" do
    before do
      exile_rival
      go_to_main_phase!
    end

    it "lets you pay {E} to keep it" do
      game.resolve_choice!
      game.settle!

      expect(p1.energy).to eq(1)
      expect(prison.zone).to eq(game.battlefield)
      expect(game.exile.cards).to include(rival.card)
    end

    it "sacrifices it, returning the permanent, when you decline" do
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(2)
      expect(p1.graveyard.cards.map(&:name)).to include("Static Prison")
      expect(game.exile.cards).not_to include(rival.card)
    end
  end

  it "sacrifices it without offering a choice when you have no energy" do
    exile_rival
    p1.pay_energy!(2)
    go_to_main_phase!
    game.settle!

    expect(game.choices).to be_empty
    expect(p1.graveyard.cards.map(&:name)).to include("Static Prison")
  end

  it "doesn't trigger on an opponent's first main phase" do
    exile_rival
    go_to_main_phase_for!(p2)
    game.settle!

    expect(game.choices).to be_empty
    expect(p1.energy).to eq(2)
    expect(prison.zone).to eq(game.battlefield)
  end
end
