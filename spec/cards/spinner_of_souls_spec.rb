# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpinnerOfSouls do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:spinner) { ResolvePermanent("Spinner of Souls", owner: p1) }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p1) }

  let(:lands) { 2.times.map { Card("Island", owner: p1) } }
  let(:bears_card) { Card("Grizzly Bears", owner: p1) }
  let(:trailing) { Card("Island", owner: p1) }

  def stock_library(*cards)
    p1.library.items.clear
    cards.reverse_each { p1.library.add(_1) }
  end

  it "is a 4/3 Spider Spirit with reach" do
    expect([spinner.power, spinner.toughness]).to eq([4, 3])
    expect(spinner).to be_reach
  end

  it "may reveal until a creature, put it in hand, and the rest on the bottom" do
    stock_library(*lands, bears_card, trailing)
    victim.destroy!
    game.settle!
    game.resolve_choice!

    expect(p1.hand.cards).to include(bears_card)
    expect(p1.library.items.first).to eq(trailing)
    expect(p1.library.items.last(2)).to match_array(lands)
    expect(p1.library.count).to eq(3)
  end

  it "does nothing when you decline" do
    stock_library(*lands, bears_card, trailing)
    victim.destroy!
    game.settle!
    game.skip_choice!

    expect(p1.hand.cards).not_to include(bears_card)
    expect(p1.library.count).to eq(4)
    expect(p1.library.items.first).to eq(lands.first)
  end

  it "puts the whole library on the bottom (in some order) when there is no creature card" do
    stock_library(*lands, trailing)
    victim.destroy!
    game.settle!
    hand_before = p1.hand.count
    game.resolve_choice!

    expect(p1.hand.count).to eq(hand_before)
    expect(p1.library.items).to match_array([*lands, trailing])
  end

  it "triggers for another nontoken creature of yours, but not a token, an opponent's creature, or itself" do
    stock_library(*lands, bears_card, trailing)
    token = Magic::Permanent.resolve(game:, owner: p1, card: victim.copiable_card, token: true, copy: true, cast: false)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    [token, theirs, spinner].each(&:destroy!)
    game.settle!

    expect(game.choices).to be_empty
  end
end
