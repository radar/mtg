# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LilianasDevotee do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:devotee) { ResolvePermanent("Liliana's Devotee", owner: p1) }

  def zombies = p1.creatures.by_name("Zombie")

  it "is a 2/3 Human Warlock" do
    expect([devotee.power, devotee.toughness]).to eq([2, 3])
  end

  it "gives Zombies you control +1/+0, but not other creatures or an opponent's Zombies" do
    mine = ResolvePermanent("Walking Corpse", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Walking Corpse", owner: p2)
    game.tick!

    expect(mine.power).to eq(3)
    expect(bears.power).to eq(2)
    expect(theirs.power).to eq(2)
  end

  describe "at the beginning of your end step" do
    before { p1.add_mana(black: 2) }

    it "may pay {1}{B} for a 2/2 black Zombie if a creature died this turn" do
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      game.settle!
      current_turn.end!
      game.settle!
      game.resolve_choice!(payment: { generic: { black: 1 }, black: 1 })
      game.settle!
      game.tick!

      expect(zombies.count).to eq(1)
      expect(zombies.first.power).to eq(3) # 2/2 plus Devotee's +1/+0
    end

    it "makes no Zombie when you decline" do
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      game.settle!
      current_turn.end!
      game.settle!
      game.skip_choice!

      expect(zombies.count).to eq(0)
    end

    it "does nothing if no creature died this turn" do
      current_turn.end!
      game.settle!

      expect(game.choices).to be_empty
    end

    it "offers nothing if you can't pay" do
      p1.mana_pool.clear if p1.mana_pool.respond_to?(:clear)
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      game.settle!
      current_turn.end!
      game.settle!

      expect(game.choices.count).to be <= 1
    end
  end
end
