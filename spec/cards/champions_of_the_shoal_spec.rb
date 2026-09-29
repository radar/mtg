# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChampionsOfTheShoal do
  include_context "two player game"

  def stun_counters(permanent) = permanent.counters.of_type(Magic::Counters::Stun).count

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 4/6 Merfolk Soldier" do
    shoal = ResolvePermanent("Champions Of The Shoal", owner: p1)
    game.skip_choice!
    expect([shoal.power, shoal.toughness]).to eq([4, 6])
    expect(shoal.type?("Merfolk")).to eq(true)
  end

  it "taps up to one target creature and stuns it when it enters" do
    ResolvePermanent("Champions Of The Shoal", owner: p1)
    expect(game.choices.last.choice_amount).to eq(0..1)
    game.resolve_choice!(target: rival)

    expect(rival).to be_tapped
    expect(stun_counters(rival)).to eq(1)
  end

  it "may choose nothing" do
    ResolvePermanent("Champions Of The Shoal", owner: p1)
    game.skip_choice!
    expect(rival).to be_untapped
    expect(stun_counters(rival)).to eq(0)
  end

  it "does it again whenever it becomes tapped" do
    shoal = ResolvePermanent("Champions Of The Shoal", owner: p1)
    game.skip_choice!
    shoal.tap!
    game.settle!
    game.resolve_choice!(target: rival)
    expect(stun_counters(rival)).to eq(1)
  end

  it "doesn't trigger when another creature becomes tapped" do
    ResolvePermanent("Champions Of The Shoal", owner: p1)
    game.skip_choice!
    other.tap!
    game.settle!
    expect(game.choices).to be_empty
  end

  describe "the additional cost" do
    let(:card) { Card("Champions Of The Shoal", owner: p1) }

    it "exiles a Merfolk and returns it to hand when it leaves" do
      merfolk = ResolvePermanent("Triton Shorethief", owner: p1)
      p1.hand.add(card)
      go_to_main_phase!
      p1.add_mana(blue: 4)
      p1.cast(card: card) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1).pay_behold(merfolk) }
      game.stack.resolve!
      expect(merfolk.card.zone).to be_exile
      game.skip_choice!

      p1.creatures.find { _1.card == card }.destroy!
      game.settle!
      expect(merfolk.card.zone).to be_hand
    end
  end
end
