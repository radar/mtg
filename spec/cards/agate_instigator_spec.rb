# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AgateInstigator do
  include_context "two player game"

  let(:card) { Card("Agate Instigator", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(card)
  end

  def agates = p1.creatures.by_name("Agate Instigator")

  it "is a 1/3 Lizard Rogue" do
    permanent = ResolvePermanent("Agate Instigator", owner: p1)

    expect(permanent.power).to eq(1)
    expect(permanent.toughness).to eq(3)
    expect(permanent.type?("Lizard")).to be(true)
    expect(permanent.type?("Rogue")).to be(true)
  end

  context "creature entered trigger" do
    let!(:agate) { ResolvePermanent("Agate Instigator", owner: p1) }

    it "deals 1 damage to each opponent when another creature you control enters" do
      ResolvePermanent("Grizzly Bears", owner: p1)

      expect(p2.life).to eq(19)
      expect(p1.life).to eq(20)
    end

    it "doesn't trigger when an opponent's creature enters" do
      ResolvePermanent("Grizzly Bears", owner: p2)

      expect(p2.life).to eq(20)
    end
  end

  it "doesn't damage anyone when it enters itself" do
    p1.add_mana(red: 2)
    p1.cast(card: card) { |action| action.pay_mana(generic: { red: 1 }, red: 1) }
    game.settle!

    expect(agates.count).to eq(1)
    expect(p2.life).to eq(20)
  end

  context "offspring" do
    it "creates a 1/1 token copy when offspring {1}{R} is paid, which triggers the original" do
      p1.add_mana(red: 4)
      p1.cast(card: card) do |action|
        action.pay_mana(generic: { red: 1 }, red: 1)
        action.pay_offspring(generic: { red: 1 }, red: 1)
      end
      game.settle!

      expect(agates.count).to eq(2)
      token = agates.find(&:token?)
      expect(token.power).to eq(1)
      expect(token.toughness).to eq(1)
      expect(p1.mana_pool.values.sum).to eq(0)
      expect(p2.life).to eq(19)
    end

    it "can't pay offspring twice without a second offspring cost" do
      p1.add_mana(red: 6)
      action = Magic::Actions::Cast.new(game: game, player: p1, card: card)
      action.pay_offspring(generic: { red: 1 }, red: 1)

      expect { action.pay_offspring(generic: { red: 1 }, red: 1) }.to raise_error(/no unpaid offspring cost/)
    end

    context "with Zinnia, Valley's Voice granting a second offspring cost" do
      let!(:zinnia) { ResolvePermanent("Zinnia, Valley's Voice", owner: p1) }

      it "has both its own offspring cost and Zinnia's" do
        action = Magic::Actions::Cast.new(game: game, player: p1, card: card)

        expect(action.offspring_costs.map(&:cost)).to eq([{ generic: 1, red: 1 }, { generic: 2 }])
      end

      it "creates a token copy for each offspring cost paid" do
        p1.add_mana(red: 6)
        p1.cast(card: card) do |action|
          action.pay_mana(generic: { red: 1 }, red: 1)
          action.pay_offspring(generic: { red: 1 }, red: 1)
          action.pay_offspring(generic: { red: 2 })
        end
        game.settle!

        tokens = agates.select(&:token?)
        expect(agates.count).to eq(3)
        expect(tokens.count).to eq(2)
        expect(tokens.map(&:power)).to all(eq(1))
        expect(tokens.map(&:toughness)).to all(eq(1))
        expect(p1.mana_pool.values.sum).to eq(0)

        # The first token triggers the original; the second triggers the original and the first token.
        expect(p2.life).to eq(17)

        # Zinnia: the two tokens have base power 1; the original Agate does too.
        game.tick!
        expect(zinnia.power).to eq(4)
      end

      it "creates one token when only one offspring cost is paid" do
        p1.add_mana(red: 4)
        p1.cast(card: card) do |action|
          action.pay_mana(generic: { red: 1 }, red: 1)
          action.pay_offspring(generic: { red: 1 }, red: 1)
        end
        game.settle!

        expect(agates.select(&:token?).count).to eq(1)
      end
    end
  end
end
