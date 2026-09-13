# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RoamingThrone do
  include_context "two player game"

  subject!(:throne) { ResolvePermanent("Roaming Throne", owner: p1) }

  it "is a 4/4 artifact creature Golem" do
    expect(throne.power).to eq(4)
    expect(throne.toughness).to eq(4)
    expect(throne.type?("Golem")).to eq(true)
  end

  it "presents a choice to choose a creature type on ETB" do
    expect(game.choices.last).to be_a(described_class::CreatureTypeChoice)
  end

  context "chosen creature type" do
    before do
      game.resolve_choice!(creature_type: "Elf")
      game.tick!
    end

    it "is the chosen type in addition to its other types" do
      expect(throne.type?("Elf")).to eq(true)
    end

    it "keeps its other types" do
      expect(throne.type?("Golem")).to eq(true)
    end
  end

  context "Ward {2}" do
    before { game.resolve_choice!(creature_type: "Golem") }

    context "when an opponent casts a spell targeting it and pays {2}" do
      before do
        p2.add_mana(red: 1, colorless: 2)
        action = cast_action(card: Card("Lightning Bolt", owner: p2), player: p2)
        action.pay_mana(red: 1)
        action.targeting(throne)
        game.take_action(action)

        game.resolve_choice!(payment: { colorless: 2 })
      end

      it "spends the mana" do
        expect(p2.mana_pool[:colorless]).to eq(0)
      end

      it "does not counter the spell" do
        game.stack.resolve!

        expect(throne.damage).to eq(3)
      end
    end

    context "when an opponent casts a spell targeting it and does not pay" do
      let(:bolt) { Card("Lightning Bolt", owner: p2) }

      before do
        p2.add_mana(red: 1)
        action = cast_action(card: bolt, player: p2)
        action.pay_mana(red: 1)
        action.targeting(throne)
        game.take_action(action)

        game.resolve_choice!(payment: {})
      end

      it "counters the spell" do
        expect(p2.graveyard).to include(bolt)
      end

      it "does not deal damage" do
        game.stack.resolve!

        expect(throne.damage).to eq(0)
      end
    end

    context "when the controller casts a spell targeting it" do
      before do
        p1.add_mana(red: 1)
        action = cast_action(card: Card("Lightning Bolt", owner: p1), player: p1)
        action.pay_mana(red: 1)
        action.targeting(throne)
        game.take_action(action)
      end

      it "does not present a ward choice" do
        expect(game.choices.last).to be_nil
      end
    end
  end

  context "triggered abilities of another creature you control of the chosen type" do
    context "when the chosen type matches" do
      before do
        game.resolve_choice!(creature_type: "Elf")
        game.tick!

        ResolvePermanent("Elderfang Ritualist", owner: p1)
        ResolvePermanent("Dwynen's Elite", owner: p1)
      end

      it "triggers an additional time" do
        expect(p1.creatures.by_name("Elf Warrior").count).to eq(2)
      end
    end

    context "when the chosen type does not match" do
      before do
        game.resolve_choice!(creature_type: "Merfolk")
        game.tick!

        ResolvePermanent("Elderfang Ritualist", owner: p1)
        ResolvePermanent("Dwynen's Elite", owner: p1)
      end

      it "triggers only once" do
        expect(p1.creatures.by_name("Elf Warrior").count).to eq(1)
      end
    end

    context "when it's another creature's controller who doesn't match" do
      before do
        game.resolve_choice!(creature_type: "Elf")
        game.tick!

        ResolvePermanent("Elderfang Ritualist", owner: p2)
        ResolvePermanent("Dwynen's Elite", owner: p2)
      end

      it "triggers only once" do
        expect(p2.creatures.by_name("Elf Warrior").count).to eq(1)
      end
    end
  end
end
