# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReverentHowl do
  include_context "two player game"

  let(:howl) { Card("Reverent Howl", owner: p1) }

  before do
    p1.hand.add(howl)
    p1.add_mana(black: 3)
  end

  def cast_with(mode, target)
    p1.cast(card: howl) do |action|
      action.pay_mana(generic: { black: 2 }, black: 1)
      action.choose_mode(mode) { _1.targeting(target) }
    end
    game.stack.resolve!
    game.settle!
  end

  it "has target player draw two cards and lose 2 life" do
    hand = p1.hand.count
    cast_with(described_class::DrawAndLose, p1)

    expect(p1.hand.count).to eq(hand - 1 + 2)
    expect(p1.life).to eq(18)
  end

  it "can target an opponent with the first mode" do
    hand = p2.hand.count
    cast_with(described_class::DrawAndLose, p2)

    expect(p2.hand.count).to eq(hand + 2)
    expect(p2.life).to eq(18)
  end

  it "gives target creature +2/+2 and lifelink until end of turn" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_with(described_class::Pump, bear)
    game.tick!

    expect([bear.power, bear.toughness]).to eq([4, 4])
    expect(bear).to be_lifelink
  end
end
