# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DevotedDuelist do
  include_context "two player game"

  let!(:duelist) { ResolvePermanent("Devoted Duelist", owner: p1) }

  before do
    go_to_main_phase!
    p1.add_mana(red: 4)
  end

  def cast_bolt
    card = Card("Lightning Bolt")
    p1.hand.add(card)
    p1.cast(card:) do |action|
      action.pay_mana(red: 1)
      action.targeting(p2)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/1 with haste" do
    expect([duelist.power, duelist.toughness]).to eq([2, 1])
    expect(duelist).to have_keyword(Magic::Cards::Keywords::HASTE)
  end

  it "deals 1 damage to each opponent on the second spell each turn" do
    cast_bolt
    expect(p2.life).to eq(17)
    cast_bolt
    expect(p2.life).to eq(13)
  end

  it "doesn't count an opponent's spells" do
    go_to_main_phase_for!(p2)
    p2.add_mana(red: 2)
    2.times do
      card = Card("Lightning Bolt")
      p2.hand.add(card)
      p2.cast(card:) do |action|
        action.pay_mana(red: 1)
        action.targeting(p1)
      end
      game.stack.resolve!
    end
    game.settle!
    expect(p2.life).to eq(20)
  end
end
