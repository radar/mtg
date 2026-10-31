# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MorgulKnifeWound do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:ally) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def cast_wound(target = bears)
    p1.add_mana(black: 2)
    p1.cast(card: Card("Morgul-Knife Wound")) do
      _1.auto_pay_mana
      _1.targeting(target)
    end
    game.stack.resolve!
    game.tick!
  end

  def upkeep(player)
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: player))
    game.settle!
  end

  it "gives the enchanted creature -3/-0 and no one else" do
    cast_wound

    expect([bears.power, bears.toughness]).to eq([-1, 2])
    expect([ally.power, ally.toughness]).to eq([2, 2])
  end

  it "can enchant any creature" do
    expect(Card("Morgul-Knife Wound").target_choices).to include(bears, ally)
  end

  context "at the beginning of the enchanted creature's controller's upkeep" do
    before { cast_wound }

    it "keeps the creature when its controller pays 2 life" do
      upkeep(p2)
      game.resolve_choice!

      expect(p2.life).to eq(18)
      expect(p2.creatures).to include(bears)
    end

    it "exiles the creature when its controller declines" do
      upkeep(p2)
      game.skip_choice!
      game.settle!

      expect(p2.life).to eq(20)
      expect(p2.creatures).not_to include(bears)
      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
      expect(p2.creatures).to include(ally)
    end

    it "exiles the creature without a choice when its controller has under 2 life" do
      p2.lose_life(19)
      upkeep(p2)
      game.settle!

      expect(game.choices).to be_empty
      expect(p2.life).to eq(1)
      expect(p2.creatures).not_to include(bears)
    end

    it "does not trigger on the Aura controller's upkeep" do
      upkeep(p1)

      expect(game.choices).to be_empty
      expect(p2.creatures).to include(bears)
      expect(p1.life).to eq(20)
    end

    it "asks the new controller after a control change" do
      bears.controller = p1
      upkeep(p2)
      expect(game.choices).to be_empty

      upkeep(p1)
      expect(game.choices.size).to eq(1)
      game.resolve_choice!
      expect(p1.life).to eq(18)
      expect(p1.creatures).to include(bears)
    end
  end
end
