# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::QuestForTheNecropolis do
  include_context "two player game"

  let!(:quest) { ResolvePermanent("Quest For The Necropolis", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p2) }

  before do
    go_to_main_phase!
    p2.graveyard.add(bears)
  end

  def quest_counters = quest.counters.of_type(Magic::Counters["quest"]).count

  def reanimate!(mana:, payment:)
    p1.add_mana(**mana)
    p1.activate_ability(ability: quest.activated_abilities.first) do |a|
      a.pay_mana(**payment)
      a.targeting(bears)
    end
    game.stack.resolve!
    game.settle!
  end

  it "gets a quest counter whenever a land enters under your control" do
    ResolvePermanent("Forest", owner: p1)
    game.settle!

    expect(quest_counters).to eq(1)
  end

  it "gets no quest counter when a land enters under an opponent's control" do
    ResolvePermanent("Forest", owner: p2)
    game.settle!

    expect(quest_counters).to eq(0)
  end

  it "can only be activated as a sorcery" do
    skip_to_combat!

    expect do
      reanimate!(mana: { black: 6 }, payment: { generic: { black: 5 }, black: 1 })
    end.to raise_error(Magic::IllegalAction)
  end

  it "reanimates a creature from any graveyard under your control for {5}{B}" do
    reanimate!(mana: { black: 6 }, payment: { generic: { black: 5 }, black: 1 })

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    expect(game.battlefield.permanents).not_to include(quest)
  end

  it "costs {1} less for each quest counter" do
    3.times { ResolvePermanent("Forest", owner: p1) }
    game.settle!

    reanimate!(mana: { black: 3 }, payment: { generic: { black: 2 }, black: 1 })

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end
end
