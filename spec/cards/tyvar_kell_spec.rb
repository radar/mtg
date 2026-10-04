# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TyvarKell do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:tyvar) { ResolvePermanent("Tyvar Kell", owner: p1) }
  let!(:elf) { ResolvePermanent("Llanowar Elves", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def activate(index, &)
    p1.activate_loyalty_ability(ability: tyvar.loyalty_abilities[index], &)
    game.stack.resolve!
    game.tick!
  end

  it "has 3 loyalty" do
    expect(tyvar.loyalty).to eq(3)
  end

  context "static ability" do
    it "gives Elves you control '{T}: Add {B}'" do
      game.tick!
      ability = elf.activated_abilities.find { _1.is_a?(described_class::BlackManaAbility) }
      expect(ability).not_to be_nil

      p1.activate_ability(ability: ability)
      expect(p1.mana_pool[:black]).to eq(1)
    end

    it "doesn't give it to non-Elves" do
      game.tick!
      expect(bears.activated_abilities.any? { _1.is_a?(described_class::BlackManaAbility) }).to be false
    end
  end

  context "+1" do
    it "puts a +1/+1 counter on the target Elf, untaps it and gives it deathtouch" do
      elf.tap!
      activate(0) { _1.targeting(elf) }

      expect(tyvar.loyalty).to eq(4)
      expect(elf.power).to eq(2)
      expect(elf).not_to be_tapped
      expect(elf.deathtouch?).to be true
    end

    it "can be activated with no target" do
      activate(0)

      expect(tyvar.loyalty).to eq(4)
    end

    it "can't target a non-Elf" do
      expect { activate(0) { _1.targeting(bears) } }.to raise_error(StandardError)
    end
  end

  context "0" do
    it "creates a 1/1 green Elf Warrior token" do
      activate(1)

      token = p1.creatures.find(&:token?)
      expect(token.name).to eq("Elf Warrior")
      expect(token.power).to eq(1)
      expect(token.type?("Elf")).to be true
    end
  end

  context "-6" do
    before { tyvar.change_loyalty!(6) }

    it "gets an emblem: Elf spells gain haste and draw two cards" do
      activate(2)
      expect(game.emblems.count).to eq(1)

      hand_size = p1.hand.count
      p1.add_mana(green: 2)
      p1.cast(card: Card("Elvish Warmaster", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      expect(p1.hand.count).to eq(hand_size + 2)

      game.stack.resolve!
      game.tick!
      warmaster = p1.permanents.by_name("Elvish Warmaster").first
      expect(warmaster).to have_keyword(:haste)
    end

    it "doesn't trigger for a non-Elf spell" do
      activate(2)

      hand_size = p1.hand.count
      p1.add_mana(green: 2)
      p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      expect(p1.hand.count).to eq(hand_size)
    end
  end
end
