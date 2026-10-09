# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AlongTheCrookedWay do
  include_context "two player game"
  before { go_to_main_phase! }

  def armies = p1.creatures.select { _1.type?("Army") }

  let!(:dead_bears) { Card("Grizzly Bears", owner: p1) }
  let!(:dead_land) { Card("Forest", owner: p1) }

  before do
    p1.graveyard.add(dead_bears)
    p1.graveyard.add(dead_land)
  end

  it "returns a creature card from your graveyard to your hand when it enters" do
    ResolvePermanent("Along The Crooked Way", owner: p1)
    game.resolve_choice!(target: dead_bears) if game.choices.any?
    game.settle!

    expect(dead_bears.zone).to be_hand
    expect(dead_land.zone).to be_graveyard
  end

  it "amasses Goblins 1 whenever a creature card leaves your graveyard" do
    ResolvePermanent("Along The Crooked Way", owner: p1)
    game.resolve_choice!(target: dead_bears) if game.choices.any?
    game.settle!
    game.tick!

    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(1)
    expect(armies.first.type?("Goblin")).to be(true)
  end

  it "doesn't amass when a noncreature card leaves your graveyard" do
    ResolvePermanent("Along The Crooked Way", owner: p1)
    game.resolve_choice!(target: dead_bears) if game.choices.any?
    game.settle!
    dead_land.move_to_hand!
    game.settle!
    game.tick!

    expect(armies.first.power).to eq(1)
  end

  it "gives Goblins and Orcs you control menace for {1}{B}" do
    goblin = ResolvePermanent("Azog, Moria's Ruin", owner: p1)
    game.choices.clear
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    way = ResolvePermanent("Along The Crooked Way", owner: p1)
    game.choices.clear
    p1.add_mana(black: 2)
    p1.activate_ability(ability: way.activated_abilities.first) { _1.pay_mana(black: 1, generic: { black: 1 }) }
    game.stack.resolve!
    game.tick!

    expect(goblin.menace?).to be(true)
    expect(bears.menace?).to be(false)
  end
end
