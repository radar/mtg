# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChampionsOfThePerfect do
  include_context "two player game"

  let(:card) { Card("Champions Of The Perfect", owner: p1) }
  let(:champions) { p1.creatures.find { _1.card == card } }

  def cast_beholding(payment)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(green: 4)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 3 }, green: 1).pay_behold(payment) }
    game.stack.resolve!
    game.tick!
  end

  it "is a 6/6 Elf Warrior" do
    perfect = ResolvePermanent("Champions Of The Perfect", owner: p1)
    expect([perfect.power, perfect.toughness]).to eq([6, 6])
    expect(perfect.type?("Elf")).to eq(true)
  end

  it "exiles an Elf as it is cast and returns it to hand when it leaves" do
    elf = ResolvePermanent("Wood Elves", owner: p1)
    cast_beholding(elf)
    expect(elf.card.zone).to be_exile

    champions.destroy!
    game.settle!
    expect(elf.card.zone).to be_hand
  end

  it "can't behold a non-Elf" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(green: 4)
    expect { p1.cast(card: card) { |a| a.pay_mana(generic: { green: 3 }, green: 1).pay_behold(bears) } }.to raise_error(/can't be beheld/)
  end

  describe "the cast trigger" do
    before { cast_beholding(ResolvePermanent("Wood Elves", owner: p1)) }

    let(:bears) { Card("Grizzly Bears", owner: p1) }
    let(:bolt) { Card("Lightning Bolt", owner: p1) }

    before do
      p1.hand.add(bears)
      p1.hand.add(bolt)
    end

    it "draws a card whenever you cast a creature spell" do
      p1.add_mana(green: 2)
      # the Bears leave your hand (-1) and the trigger draws a card (+1)
      expect do
        p1.cast(card: bears) { |a| a.auto_pay_mana }
        game.settle!
      end.not_to(change { p1.hand.count })
      expect(bears.zone).to be_battlefield
    end

    it "doesn't draw for a noncreature spell" do
      p1.add_mana(red: 1)
      expect do
        p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
        game.settle!
      end.to change { p1.hand.count }.by(-1)
    end

    it "doesn't draw for the opponent's creature spells" do
      game.next_turn
      go_to_main_phase!
      rival_bears = Card("Grizzly Bears", owner: p2)
      p2.hand.add(rival_bears)
      p2.add_mana(green: 2)
      expect do
        p2.cast(card: rival_bears) { |a| a.auto_pay_mana }
        game.settle!
      end.not_to(change { p1.hand.count })
    end
  end
end
