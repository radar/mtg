# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WakerOfWaves do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 7/7 Whale" do
    waker = ResolvePermanent("Waker Of Waves", owner: p1)

    expect([waker.power, waker.toughness]).to eq([7, 7])
  end

  it "gives creatures your opponents control -1/-0, but not yours" do
    ResolvePermanent("Waker Of Waves", owner: p1)
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(mine.power).to eq(2)
    expect(theirs.power).to eq(1)
  end

  describe "{1}{U}, Discard this card" do
    let(:waker) { Card("Waker Of Waves", owner: p1) }

    before do
      p1.hand.add(waker)
      p1.add_mana(blue: 2)
    end

    def activate
      p1.cycle(card: waker) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    end

    it "looks at the top two cards, putting one in hand and the other in the graveyard" do
      top_two = p1.library.cards.first(2)
      activate
      game.resolve_choice!(target: top_two.first)

      expect(waker.zone).to be_graveyard
      expect(top_two.first.zone).to be_hand
      expect(top_two.last.zone).to be_graveyard
    end

    it "only offers the top two cards" do
      top_two = p1.library.cards.first(2)
      activate

      expect(game.choices.last.choices).to eq(top_two)
    end
  end
end
