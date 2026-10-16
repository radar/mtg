# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UrzasIncubator do
  include_context "two player game"

  before { go_to_main_phase! }

  def resolve_incubator(type: "Pegasus")
    incubator = ResolvePermanent("Urza's Incubator", owner: p1)
    game.resolve_choice!(creature_type: type)
    game.tick!
    incubator
  end

  def cost_of(card, player: card.owner)
    Magic::Actions::Cast.new(card: card, player: player, game: game).mana_cost.cost
  end

  it "is a colorless artifact costing {3}" do
    incubator = ResolvePermanent("Urza's Incubator", owner: p1)

    expect(incubator.type?("Artifact")).to be(true)
    expect(incubator.cmc).to eq(3)
  end

  it "asks its controller to choose a creature type as it enters and stores the answer" do
    incubator = ResolvePermanent("Urza's Incubator", owner: p1)

    expect(game.choices.first).to be_a(Magic::Choice::ChooseCreatureTypeForPermanent)
    game.resolve_choice!(creature_type: "Pegasus")

    expect(incubator.chosen_creature_type).to eq("Pegasus")
  end

  context "creature spells of the chosen type cost {2} less" do
    it "reduces your creature spell of the chosen type by {2}" do
      resolve_incubator
      wingmare = Card("Vryn Wingmare", owner: p1)

      expect(cost_of(wingmare)).to eq({ generic: 0, white: 1 })
    end

    it "reduces an opponent's creature spell of the chosen type too" do
      resolve_incubator
      wingmare = Card("Vryn Wingmare", owner: p2)

      expect(cost_of(wingmare)).to eq({ generic: 0, white: 1 })
    end

    it "only reduces generic mana, never colored" do
      resolve_incubator(type: "Bear")
      bears = Card("Grizzly Bears", owner: p1)

      expect(cost_of(bears)).to eq({ generic: 0, green: 1 })
    end

    it "does not reduce a creature spell of another type" do
      resolve_incubator(type: "Elf")
      wingmare = Card("Vryn Wingmare", owner: p1)

      expect(cost_of(wingmare)).to eq({ generic: 2, white: 1 })
    end

    it "does not reduce a noncreature spell" do
      resolve_incubator
      bolt = Card("Lightning Bolt", owner: p1)

      expect(cost_of(bolt)).to eq({ red: 1 })
    end

    it "makes the spell castable for the reduced cost" do
      resolve_incubator
      wingmare = Card("Vryn Wingmare", owner: p1)
      p1.hand.add(wingmare)
      p1.add_mana(white: 1)
      p1.cast(card: wingmare) { |a| a.pay_mana(white: 1) }
      game.stack.resolve!
      game.settle!

      expect(p1.creatures.map(&:card)).to include(wingmare)
      expect(p1.mana_pool.values.sum).to eq(0)
    end
  end
end
