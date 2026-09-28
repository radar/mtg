# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MistmeadowCouncil do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Mistmeadow Council", owner: p1) }

  it "costs {4}{G} without a Kithkin" do
    p1.add_mana(green: 5)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { green: 4 }, green: 1) }
    game.stack.resolve!

    expect(card.zone).to be_battlefield
  end

  it "costs {1} less with a Kithkin" do
    ResolvePermanent("Goldmeadow Nomad", owner: p1)
    p1.add_mana(green: 4)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }
    game.stack.resolve!

    expect(card.zone).to be_battlefield
  end

  it "does not get the discount from an opponent's Kithkin" do
    ResolvePermanent("Goldmeadow Nomad", owner: p2)
    p1.add_mana(green: 4)
    p1.hand.add(card)

    expect { p1.cast(card:) { |a| a.pay_mana(generic: { green: 3 }, green: 1) } }.to raise_error(StandardError)
  end

  it "draws a card when it enters" do
    p1.add_mana(green: 5)
    p1.hand.add(card)
    hand_size = p1.hand.count - 1

    p1.cast(card:) { |a| a.pay_mana(generic: { green: 4 }, green: 1) }
    game.stack.resolve!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end
