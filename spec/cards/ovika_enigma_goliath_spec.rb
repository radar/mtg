# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OvikaEnigmaGoliath do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:ovika) { ResolvePermanent("Ovika, Enigma Goliath", owner: p1) }

  def goblins = p1.creatures.select { _1.name == "Phyrexian Goblin" }

  def cast(name, player: p1, **pay)
    card = Card(name, owner: player)
    player.hand.add(card)
    player.add_mana(**pay)
    player.cast(card:) { |a| yield a }
    game.settle!
    card
  end

  it "is a 6/6 legendary flying Phyrexian Nightmare" do
    expect([ovika.power, ovika.toughness]).to eq([6, 6])
    expect(ovika).to be_flying
    expect(ovika.type?("Legendary")).to eq(true)
    expect(ovika.type?("Nightmare")).to eq(true)
  end

  describe "when you cast a noncreature spell" do
    it "creates X 1/1 red Phyrexian Goblins with haste, X being its mana value" do
      cast("Shock", red: 1) { |a| a.pay_mana(red: 1).targeting(p2) } # mana value 1
      expect(goblins.size).to eq(1)

      victim = ResolvePermanent("Grizzly Bears", owner: p2)
      cast("Doom Blade", black: 2) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(victim) } # mana value 2
      expect(goblins.size).to eq(3)
      expect(goblins.map { [_1.power, _1.toughness] }.uniq).to eq([[1, 1]])
      expect(goblins.first.colors).to eq([:red])
      expect(goblins).to all(satisfy(&:haste?))
    end

    it "doesn't trigger for a creature spell" do
      cast("Grizzly Bears", green: 2) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect(goblins).to be_empty
    end

    it "doesn't trigger for an opponent's spell" do
      cast("Shock", player: p2, red: 1) { |a| a.pay_mana(red: 1).targeting(p1) }

      expect(goblins).to be_empty
    end

    it "gives only the new tokens haste until end of turn" do
      cast("Shock", red: 1) { |a| a.pay_mana(red: 1).targeting(p2) }
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(goblins.size).to eq(1)
      expect(goblins.first.haste?).to eq(false)
    end
  end

  describe "ward—{3}, pay 3 life" do
    it "lets the spell resolve when both the mana and the life are paid" do
      p2.add_mana(red: 4)
      p2.cast(card: Card("Shock", owner: p2)) { _1.pay_mana(red: 1).targeting(ovika) }
      game.settle!
      expect(game.choices.last).to be_a(Magic::Choice::Ward)

      game.resolve_choice!(payment: { red: 3 }, pay_life: true)
      game.settle!
      expect(p2.life).to eq(17)
      expect(ovika.damage).to eq(2)
    end

    it "counters the spell when only the life is paid" do
      p2.add_mana(red: 1)
      p2.cast(card: Card("Shock", owner: p2)) { _1.pay_mana(red: 1).targeting(ovika) }
      game.settle!
      game.resolve_choice!(payment: {}, pay_life: true)
      game.settle!

      expect(ovika.damage).to eq(0)
    end

    it "counters the spell when only the mana is paid" do
      p2.add_mana(red: 4)
      p2.cast(card: Card("Shock", owner: p2)) { _1.pay_mana(red: 1).targeting(ovika) }
      game.settle!
      game.resolve_choice!(payment: { red: 3 })
      game.settle!

      expect(ovika.damage).to eq(0)
      expect(p2.life).to eq(20)
    end
  end
end
