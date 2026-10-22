# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BreakerOfCreation do
  include_context "two player game"
  before { go_to_main_phase! }

  def attack(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is an 8/4 Eldrazi" do
    breaker = ResolvePermanent("Breaker Of Creation", owner: p1)

    expect([breaker.power, breaker.toughness]).to eq([8, 4])
    expect(breaker.type?("Eldrazi")).to eq(true)
  end

  it "gains 1 life for each colorless permanent you control when cast" do
    ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Eldrazi Repurposer", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    colorless = 2
    expect(p1.permanents.count(&:colorless?)).to eq(colorless)

    card = Card("Breaker Of Creation", owner: p1)
    p1.hand.add(card)
    p1.add_mana(colorless: 8)
    expect {
      p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 6 }, colorless: 2) }
      game.settle!
    }.to change { p1.life }.by(colorless)
    expect(card.zone).not_to be_nil
  end

  it "gains no life when you control no colorless permanents" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Breaker Of Creation", owner: p1)
    p1.hand.add(card)
    p1.add_mana(colorless: 8)
    expect {
      p1.cast(card: card) { |a| a.pay_mana(generic: { colorless: 6 }, colorless: 2) }
      game.settle!
    }.not_to change { p1.life }
  end

  it "has hexproof from each color" do
    breaker = ResolvePermanent("Breaker Of Creation", owner: p1)

    Magic::Mana::COLORS.each do |color|
      expect(breaker.card.hexproof_from?(color)).to eq(true)
    end
    bolt = Card("Lightning Bolt", owner: p2)
    expect(breaker.can_be_targeted_by?(bolt)).to eq(false)
  end

  it "has annihilator 2" do
    breaker = ResolvePermanent("Breaker Of Creation", owner: p1)
    3.times { ResolvePermanent("Grizzly Bears", owner: p2) }

    attack(breaker)
    game.skip_choice!
    game.settle!

    expect(p2.permanents.size).to eq(1)
  end
end
