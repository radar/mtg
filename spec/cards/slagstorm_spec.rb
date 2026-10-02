# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Slagstorm do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:small) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:big) { ResolvePermanent("Fire Elemental", owner: p2) } # 5/4

  def cast_slagstorm(mode)
    slagstorm = Card("Slagstorm", owner: p1)
    p1.add_mana(red: 3)
    p1.cast(card: slagstorm) do |a|
      a.pay_mana(generic: { red: 1 }, red: 2)
      a.choose_mode(slagstorm.modes[mode])
    end
    game.stack.resolve!
    game.tick!
  end

  it "deals 3 damage to each creature" do
    cast_slagstorm(0)

    expect(small.card.zone).to be_graveyard
    expect(big.damage).to eq(3)
    expect(p2.life).to eq(20)
  end

  it "deals 3 damage to each player" do
    cast_slagstorm(1)

    expect(p1.life).to eq(17)
    expect(p2.life).to eq(17)
    expect(small.damage).to eq(0)
  end
end
