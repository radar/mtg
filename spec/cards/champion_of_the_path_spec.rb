# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChampionOfThePath do
  include_context "two player game"

  let(:card) { Card("Champion Of The Path", owner: p1) }
  let(:champion) { p1.creatures.find { _1.card == card } }

  def cast_beholding(payment)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(red: 4)
    p1.cast(card: card) { |a| a.pay_mana(generic: { red: 3 }, red: 1).pay_behold(payment) }
    game.stack.resolve!
    game.tick!
  end

  it "is a 7/3 Elemental Sorcerer" do
    path = ResolvePermanent("Champion Of The Path", owner: p1)
    expect([path.power, path.toughness]).to eq([7, 3])
    expect(path.type?("Elemental")).to eq(true)
  end

  it "exiles an Elemental you control as it is cast, and gives it back when it leaves" do
    elemental = ResolvePermanent("Flame-Chain Mauler", owner: p1)
    cast_beholding(elemental)
    expect(elemental.card.zone).to be_exile

    champion.destroy!
    game.settle!
    expect(elemental.card.zone).to be_hand
  end

  describe "the enters trigger" do
    let!(:elemental) { ResolvePermanent("Flame-Chain Mauler", owner: p1) }

    before { cast_beholding(elemental) }

    it "deals damage equal to another Elemental's power to each opponent when it enters" do
      ResolvePermanent("Shinestriker", owner: p1) # a 3/3 Elemental
      expect(p2.life).to eq(17)
      ResolvePermanent("Flame-Chain Mauler", owner: p1)
      expect(p2.life).to eq(15)
    end

    it "ignores non-Elementals and an opponent's Elementals" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Shinestriker", owner: p2)
      expect(p2.life).to eq(20)
    end

    it "doesn't trigger for itself" do
      expect(p2.life).to eq(20)
    end
  end
end
