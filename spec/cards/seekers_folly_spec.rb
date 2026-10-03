# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SeekersFolly do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:big) { ResolvePermanent("Fire Elemental", owner: p2) } # 5/4

  def cast_folly(mode, target: nil)
    folly = Card("Seeker's Folly", owner: p1)
    p1.add_mana(black: 3)
    p1.cast(card: folly) do |a|
      a.pay_mana(generic: { black: 2 }, black: 1)
      a.choose_mode(folly.modes[mode]) { |m| m.targeting(target) if target }
    end
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "makes target opponent discard two cards" do
    hand_size = p2.hand.count
    cast_folly(0, target: p2)
    2.times { game.resolve_choice!(card: p2.hand.first) }

    expect(p2.hand.count).to eq(hand_size - 2)
  end

  it "gives creatures your opponents control -1/-1 until end of turn" do
    cast_folly(1)

    expect([rival.power, rival.toughness]).to eq([1, 1])
    expect([big.power, big.toughness]).to eq([4, 3])
  end

  it "doesn't shrink your own creatures" do
    cast_folly(1)

    expect([mine.power, mine.toughness]).to eq([2, 2])
  end
end
