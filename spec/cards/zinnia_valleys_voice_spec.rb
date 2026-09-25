# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ZinniaValleysVoice do
  include_context "two player game"

  let!(:zinnia) { ResolvePermanent("Zinnia, Valley's Voice", owner: p1) }

  before { go_to_main_phase! }

  it "is a legendary 1/3 Bird Bard with flying" do
    expect(zinnia).to be_legendary
    expect(zinnia.power).to eq(1)
    expect(zinnia.toughness).to eq(3)
    expect(zinnia).to have_keyword(Magic::Cards::Keywords::FLYING)
  end

  context "power boost" do
    it "gets +1/+0 for each other creature you control with base power 1" do
      ResolvePermanent("Llanowar Elves", owner: p1)
      ResolvePermanent("Llanowar Elves", owner: p1)
      game.tick!

      expect(zinnia.power).to eq(3)
      expect(zinnia.toughness).to eq(3)
    end

    it "doesn't count creatures with a different base power" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!

      expect(zinnia.power).to eq(1)
    end

    it "doesn't count an opponent's creatures" do
      ResolvePermanent("Llanowar Elves", owner: p2)
      game.tick!

      expect(zinnia.power).to eq(1)
    end
  end

  context "offspring" do
    let(:bears) { Card("Grizzly Bears", owner: p1) }

    before { p1.hand.add(bears) }

    it "creates a 1/1 token copy when the offspring cost is paid" do
      p1.add_mana(green: 4)
      p1.cast(card: bears) do |action|
        action.pay_mana(generic: { green: 1 }, green: 1)
        action.pay_offspring(generic: { green: 2 })
      end
      game.settle!

      bears_on_field = p1.creatures.by_name("Grizzly Bears")
      expect(bears_on_field.count).to eq(2)

      token = bears_on_field.find(&:token?)
      expect(token.power).to eq(1)
      expect(token.toughness).to eq(1)
      expect(bears_on_field.find { !_1.token? }.power).to eq(2)
      expect(p1.mana_pool.values.sum).to eq(0)

      game.next_turn
      game.tick!
      expect(token.power).to eq(1)
      expect(token.toughness).to eq(1)
    end

    it "counts the offspring token toward Zinnia's power boost" do
      p1.add_mana(green: 4)
      p1.cast(card: bears) do |action|
        action.pay_mana(generic: { green: 1 }, green: 1)
        action.pay_offspring(generic: { green: 2 })
      end
      game.settle!
      game.tick!

      expect(zinnia.power).to eq(2)
    end

    it "creates no token when the offspring cost isn't paid" do
      p1.add_mana(green: 2)
      p1.cast(card: bears) do |action|
        action.pay_mana(generic: { green: 1 }, green: 1)
      end
      game.settle!

      expect(p1.creatures.by_name("Grizzly Bears").count).to eq(1)
    end

    it "doesn't grant offspring to noncreature spells" do
      shock = Card("Shock", owner: p1)
      p1.hand.add(shock)
      action = Magic::Actions::Cast.new(game: game, player: p1, card: shock)

      expect(action.offspring_cost).to be_nil
    end

    it "doesn't grant offspring to an opponent's creature spells" do
      opponent_bears = Card("Grizzly Bears", owner: p2)
      action = Magic::Actions::Cast.new(game: game, player: p2, card: opponent_bears)

      expect(action.offspring_cost).to be_nil
    end
  end
end
