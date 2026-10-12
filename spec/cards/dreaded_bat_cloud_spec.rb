# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DreadedBatCloud do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Dreaded Bat-Cloud".gsub("-", " "), owner: p1) }

  it "is a 4/2 flying deathtouch Bat" do
    bat = ResolvePermanent("Dreaded Bat Cloud", owner: p1)
    expect([bat.power, bat.toughness]).to eq([4, 2])
    expect(bat.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
    expect(bat.has_keyword?(Magic::Cards::Keywords::DEATHTOUCH)).to eq(true)
  end

  it "costs {4}{B} when no creature died this turn" do
    p1.hand.add(card)
    p1.add_mana(black: 5)
    p1.cast(card: card) { _1.pay_mana(generic: { black: 4 }, black: 1) }
    game.stack.resolve!
    expect(game.battlefield.by_name("Dreaded Bat-Cloud").count).to eq(1)
  end

  it "costs {1}{B} if a creature died this turn" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card: card) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    expect(game.battlefield.by_name("Dreaded Bat-Cloud").count).to eq(1)
  end
end
