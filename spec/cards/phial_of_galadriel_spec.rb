# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PhialOfGaladriel do
  include_context "two player game"

  let!(:phial) { ResolvePermanent("Phial Of Galadriel", owner: p1) }

  def draw_effect(player, amount = 1)
    phial.trigger_effect(:draw_cards, player:, number_to_draw: amount)
    game.settle!
  end

  def gain(player, amount)
    game.add_effect(Magic::Effects::GainLife.new(source: player, target: player, life: amount))
  end

  def empty_hand(player)
    player.hand.cards.to_a.dup.each { player.hand.remove(_1) }
  end

  it "is a legendary artifact" do
    expect(phial).to be_legendary
    expect(phial).to be_artifact
  end

  it "draws two cards instead of one while you have no cards in hand" do
    empty_hand(p1)
    draw_effect(p1)

    expect(p1.hand.count).to eq(2)
  end

  it "draws two instead of the first card of a multi-card draw, the rest with a card in hand" do
    empty_hand(p1)
    draw_effect(p1, 2)

    expect(p1.hand.count).to eq(3)
  end

  it "draws normally while you have a card in hand" do
    empty_hand(p1)
    p1.hand.add(Card("Grizzly Bears", owner: p1))
    draw_effect(p1)

    expect(p1.hand.count).to eq(2)
  end

  it "doubles your draw step draw when your hand is empty" do
    empty_hand(p1)
    go_to_main_phase!

    expect(p1.hand.count).to eq(2)
  end

  it "doesn't change an opponent's draws" do
    empty_hand(p2)
    draw_effect(p2)

    expect(p2.hand.count).to eq(1)
  end

  it "doubles life gained while you have 5 or less life" do
    p1.lose_life(15)
    gain(p1, 3)

    expect(p1.life).to eq(11)
  end

  it "gains life normally while you have more than 5 life" do
    p1.lose_life(14)
    gain(p1, 3)

    expect(p1.life).to eq(9)
  end

  it "doesn't change an opponent's life gain" do
    p2.lose_life(17)
    gain(p2, 3)

    expect(p2.life).to eq(6)
  end

  it "taps for one mana of any color" do
    p1.activate_ability(ability: phial.activated_abilities.first) { |a| a.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(1)
    expect(phial).to be_tapped
  end
end
