# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LegolasMasterArcher do
  include_context "two player game"

  let!(:legolas) { ResolvePermanent("Legolas, Master Archer", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:angel) { ResolvePermanent("Serra Angel", owner: p2) }

  def cast_bolt(target, player: p1)
    player.add_mana(red: 1)
    action = cast_action(card: Card("Lightning Bolt", owner: player), player: player)
    action.pay_mana(red: 1)
    action.targeting(target)
    game.take_action(action)
    game.settle!
  end

  def choice = game.choices.first

  it "is a legendary 1/4 Elf Archer with reach" do
    expect([legolas.power, legolas.toughness]).to eq([1, 4])
    expect(legolas).to be_legendary
    expect(legolas).to have_keyword(:reach)
    expect(legolas.type?("Elf")).to eq(true)
    expect(legolas.type?("Archer")).to eq(true)
  end

  context "when you cast a spell that targets Legolas" do
    it "puts a +1/+1 counter on Legolas" do
      cast_bolt(legolas)

      expect([legolas.power, legolas.toughness]).to eq([2, 5])
    end

    it "does not offer a damage choice when the spell targets only Legolas" do
      cast_bolt(legolas)

      expect(game.choices).to be_empty
    end

    it "does not trigger when an opponent casts the spell" do
      cast_bolt(legolas, player: p2)

      expect(legolas.power).to eq(1)
    end

    it "does not trigger when the spell targets another creature you control" do
      cast_bolt(bears)

      expect(legolas.power).to eq(1)
      expect(game.choices).to be_empty
    end

    it "does not trigger when the spell targets a player" do
      cast_bolt(p2)

      expect(legolas.power).to eq(1)
      expect(game.choices).to be_empty
    end
  end

  context "when you cast a spell that targets a creature you don't control" do
    it "lets Legolas deal damage equal to its power to up to one target creature" do
      cast_bolt(angel)
      expect(choice).to be_a(described_class::DamageChoice)
      expect(choice.choices).to contain_exactly(legolas, bears, angel)
      game.resolve_choice!(target: angel)
      game.stack.resolve!
      game.tick!

      expect(angel.damage).to eq(1 + 3)
    end

    it "uses Legolas's current power" do
      legolas.add_counter(Magic::Counters::Plus1Plus1, amount: 2)
      game.settle!
      cast_bolt(angel)
      game.resolve_choice!(target: bears)
      game.stack.resolve!
      game.tick!

      expect(legolas.power).to eq(3)
      expect(bears.zone).to be_nil
      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "may choose no target" do
      cast_bolt(angel)
      game.skip_choice!
      game.stack.resolve!
      game.tick!

      expect(angel.damage).to eq(3)
    end

    it "cannot target a hexproof creature an opponent controls" do
      big = ResolvePermanent("Gigantic Big Bear", owner: p2)
      cast_bolt(angel)

      expect(choice.choices).not_to include(big)
      expect(choice.choices).to include(angel)
    end

    it "does not trigger for a spell an opponent casts" do
      cast_bolt(bears, player: p2)

      expect(game.choices).to be_empty
    end
  end

  context "when a spell does not target a creature" do
    it "does not trigger for a spell with no creature target" do
      cast_bolt(p2)

      expect(game.choices).to be_empty
      expect(angel.damage).to eq(0)
    end
  end
end
