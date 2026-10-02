# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArchmageOfRunes do
  include_context "two player game"

  let!(:archmage) { ResolvePermanent("Archmage Of Runes", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { game.tick! }

  def cast_sure_strike(player, target, **payment)
    player.cast(card: Card("Sure Strike", owner: player)) { |a| a.pay_mana(**payment).targeting(target) }
    game.settle!
  end

  it "is a 3/6 Giant Wizard" do
    expect([archmage.power, archmage.toughness]).to eq([3, 6])
  end

  it "makes instant and sorcery spells cost {1} less" do
    p1.add_mana(red: 1)
    cast_sure_strike(p1, bears, red: 1)

    expect(bears.power).to eq(5)
  end

  it "draws a card whenever you cast an instant or sorcery spell" do
    hand_size = p1.hand.count
    p1.add_mana(red: 1)
    cast_sure_strike(p1, bears, red: 1)

    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "doesn't draw when an opponent casts one" do
    hand_size = p1.hand.count
    p2.add_mana(red: 2)
    cast_sure_strike(p2, rival, generic: { red: 1 }, red: 1)

    expect(p1.hand.count).to eq(hand_size)
  end
end
