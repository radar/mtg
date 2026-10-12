# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ObliviousBookworm do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:bookworm) { ResolvePermanent("Oblivious Bookworm", owner: p1) }

  def end_step!
    current_turn.end!
    game.settle!
  end

  def manifest!
    card = p1.library.first
    game.manifest!(card, controller: p1)
    game.settle!
  end

  it "is a 2/3 Human Wizard" do
    expect([bookworm.power, bookworm.toughness]).to eq([2, 3])
  end

  it "may draw a card at your end step, then must discard a card" do
    hand_size = p1.hand.cards.count
    end_step!
    game.resolve_choice!

    expect(game.choices.last).to be_a(Magic::Choice::Discard)
    game.resolve_choice!(card: p1.hand.cards.first)
    expect(p1.hand.cards.count).to eq(hand_size)
  end

  it "may decline to draw" do
    hand_size = p1.hand.cards.count
    end_step!
    game.skip_choice!

    expect(game.choices).to be_empty
    expect(p1.hand.cards.count).to eq(hand_size)
  end

  it "doesn't discard if a permanent entered face down under your control this turn" do
    manifest!
    hand_size = p1.hand.cards.count
    end_step!
    game.resolve_choice!

    expect(game.choices).to be_empty
    expect(p1.hand.cards.count).to eq(hand_size + 1)
  end

  it "doesn't discard if you turned a permanent face up this turn" do
    bears = Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) }
    manifest!
    manifested = p1.permanents.find(&:face_down?)
    p1.add_mana(green: 2)
    p1.turn_face_up(permanent: manifested) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    expect(manifested.card).to eq(bears)

    hand_size = p1.hand.cards.count
    end_step!
    game.resolve_choice!

    expect(game.choices).to be_empty
    expect(p1.hand.cards.count).to eq(hand_size + 1)
  end

  it "discards if only an opponent put a permanent face down" do
    game.manifest!(p2.library.first, controller: p2)
    game.settle!
    end_step!
    game.resolve_choice!

    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end

  it "does nothing at an opponent's end step" do
    game.next_turn
    go_to_main_phase!
    current_turn.end!
    game.settle!

    expect(game.choices).to be_empty
  end
end
