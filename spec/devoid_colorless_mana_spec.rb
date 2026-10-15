# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Devoid, the {C} cost symbol and Eldrazi Spawn / Scion tokens" do
  include_context "two player game"

  describe "{C} in a cost" do
    it "parses to a colorless requirement, apart from generic" do
      expect(Magic::Costs::Mana.new("{2}{C}").cost).to eq(generic: 2, colorless: 1)
    end

    it "is not a color of the cost" do
      expect(Magic::Costs::Mana.new("{1}{C}{R}").colors).to eq([:red])
    end

    it "cannot be paid with colored mana" do
      p1.add_mana(red: 2)
      expect(Magic::Costs::Mana.new("{C}").can_pay?(p1)).to eq(false)
    end

    it "is not satisfied by colorless mana reserved for generic" do
      p1.add_mana(colorless: 1)
      expect(Magic::Costs::Mana.new("{1}{C}").can_pay?(p1)).to eq(false)
    end

    it "can be paid with colorless mana, leaving other mana for generic" do
      p1.add_mana(colorless: 1, red: 1)
      cost = Magic::Costs::Mana.new("{1}{C}")
      cost.auto_pay(player: p1)
      cost.finalize!(p1)

      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "can be paid by an explicit payment" do
      p1.add_mana(colorless: 1, green: 1)
      cost = Magic::Costs::Mana.new("{1}{C}")
      cost.pay!(player: p1, payment: { colorless: 1, generic: { green: 1 } })

      expect(p1.mana_pool.values.sum).to eq(0)
    end
  end

  describe "devoid" do
    let(:voidcraw) { Card("Snapping Voidcraw") }

    it "makes a card colorless regardless of its mana cost" do
      expect(voidcraw.cost.colors).to contain_exactly(:green, :blue)
      expect(voidcraw.colors).to eq([])
      expect(voidcraw).to be_colorless
    end

    it "keeps the mana cost's colors as color identity" do
      expect(voidcraw.color_identity).to contain_exactly(:green, :blue)
    end

    it "is colorless on the battlefield too" do
      permanent = ResolvePermanent("Snapping Voidcraw", owner: p1)
      expect(permanent.colors).to eq([])
      expect(permanent).to be_colorless
    end
  end

  describe "Eldrazi Spawn and Scion tokens" do
    let(:source) { ResolvePermanent("Mind Stone", owner: p1) }

    def tokens_named(name) = p1.creatures.select { _1.name == name }

    it "creates 0/1 colorless Eldrazi Spawn creature tokens" do
      source.create_eldrazi_spawn(2)
      game.settle!

      spawn = tokens_named("Eldrazi Spawn")
      expect(spawn.count).to eq(2)
      expect(spawn.first.power).to eq(0)
      expect(spawn.first.toughness).to eq(1)
      expect(spawn.first).to be_colorless
      expect(spawn.first.type?(Magic::Types::Creatures["Eldrazi"])).to eq(true)
      expect(spawn.first.type?(Magic::Types::Creatures["Spawn"])).to eq(true)
    end

    it "sacrifices a Spawn for {C}" do
      source.create_eldrazi_spawn
      game.settle!
      spawn = tokens_named("Eldrazi Spawn").first

      p1.activate_ability(ability: spawn.activated_abilities.first)
      game.settle!

      expect(p1.mana_pool[:colorless]).to eq(1)
      expect(tokens_named("Eldrazi Spawn")).to be_empty
    end

    it "creates 1/1 colorless Eldrazi Scion tokens that sacrifice for {C}" do
      source.create_eldrazi_scion
      game.settle!
      scion = tokens_named("Eldrazi Scion").first

      expect(scion.power).to eq(1)
      expect(scion.toughness).to eq(1)
      expect(scion).to be_colorless

      p1.activate_ability(ability: scion.activated_abilities.first)
      game.settle!

      expect(p1.mana_pool[:colorless]).to eq(1)
      expect(tokens_named("Eldrazi Scion")).to be_empty
    end
  end
end
