# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NyxbornUnicorn do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:small) { ResolvePermanent("Birds Of Paradise", owner: p1) }

  def unicorn = game.battlefield.permanents.find { _1.name == "Nyxborn Unicorn" }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "is a 2/2 Unicorn enchantment creature" do
    card = ResolvePermanent("Nyxborn Unicorn", owner: p1)

    expect([card.power, card.toughness]).to eq([2, 2])
    expect(card.enchantment?).to eq(true)
    expect(card.has_keyword?(:mentor)).to eq(true)
  end

  it "mentors an attacking creature with lesser power" do
    card = ResolvePermanent("Nyxborn Unicorn", owner: p1)
    attack_with(card, small)

    expect(small.power).to eq(1)
    expect(card.power).to eq(2)
  end

  it "does not mentor a creature with equal or greater power" do
    card = ResolvePermanent("Nyxborn Unicorn", owner: p1)
    attack_with(card, bears)

    expect(bears.power).to eq(2)
  end

  context "cast for its bestow cost" do
    before do
      go_to_main_phase!
      p1.add_mana(white: 4)
      p1.cast_as(:bestowed, card: Card("Nyxborn Unicorn", owner: p1)) { |a| a.pay_mana(generic: { white: 3 }, white: 1).targeting(bears) }
      game.stack.resolve!
      game.settle!
    end

    it "gives the enchanted creature +2/+2 and mentor" do
      expect(unicorn.attached_to).to eq(bears)
      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect(bears.has_keyword?(:mentor)).to eq(true)
    end

    it "mentors when the enchanted creature attacks" do
      attack_with(bears, elves)

      expect(elves.power).to eq(2)
    end
  end
end
