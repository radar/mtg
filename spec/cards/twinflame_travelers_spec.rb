# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwinflameTravelers do
  include_context "two player game"

  subject!(:travelers) { ResolvePermanent("Twinflame Travelers", owner: p1) }

  before { game.tick! }

  it "is a 3/3 Elemental Sorcerer with flying" do
    expect([travelers.power, travelers.toughness]).to eq([3, 3])
    expect(travelers).to be_flying
    expect(travelers.type?("Elemental")).to eq(true)
  end

  it "makes another Elemental's triggered ability trigger an additional time" do
    # Shinestriker (Elemental): when it enters, draw a card per colour among your permanents.
    # Travelers is blue and red, Shinestriker blue: 2 colours, so 2 cards, twice.
    expect { ResolvePermanent("Shinestriker", owner: p1) }.to change { p1.hand.count }.by(4)
  end

  it "doesn't double its own triggers or non-Elementals'" do
    expect { ResolvePermanent("Twinflame Travelers", owner: p1) }.not_to(change { p1.hand.count })
    expect { ResolvePermanent("Daxos, Blessed By The Sun", owner: p1) }.not_to(change { p1.hand.count })
  end

  it "doesn't double an opponent's Elementals" do
    # p2 controls only the blue Shinestriker: one colour, one card, not doubled.
    expect { ResolvePermanent("Shinestriker", owner: p2) }.to change { p2.hand.count }.by(1)
  end

  it "stops when it leaves the battlefield" do
    travelers.destroy!
    game.tick!
    expect { ResolvePermanent("Shinestriker", owner: p1) }.to change { p1.hand.count }.by(1)
  end
end
