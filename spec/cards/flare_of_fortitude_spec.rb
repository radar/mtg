# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlareOfFortitude do
  include_context "two player game"

  let(:flare) { Card("Flare Of Fortitude", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(flare)
  end

  def cast_flare
    p1.add_mana(white: 4)
    p1.cast(card: flare) { |a| a.pay_mana(generic: { white: 2 }, white: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "gives your permanents hexproof and indestructible until end of turn" do
    cast_flare

    expect(bears).to have_keyword(Magic::Cards::Keywords::HEXPROOF)
    expect(bears).to have_keyword(Magic::Cards::Keywords::INDESTRUCTIBLE)
  end

  it "stops your life total changing this turn" do
    cast_flare
    p1.gain_life(3)
    p1.lose_life(5)
    game.settle!

    expect(p1.life).to eq(20)
  end

  it "does not stop an opponent's life total changing" do
    cast_flare
    p2.lose_life(2)

    expect(p2.life).to eq(18)
  end

  it "lets life change again next turn" do
    cast_flare
    current_turn.end!
    current_turn.cleanup!
    2.times { game.next_turn }
    p1.lose_life(2)

    expect(p1.life).to eq(18)
  end

  it "can be cast by sacrificing a nontoken white creature" do
    hawk = ResolvePermanent("Healers Hawk", owner: p1)
    action = cast_action_as(:alternative, card: flare, player: p1)
    action.pay_cost(hawk)
    action.perform
    game.stack.resolve!
    game.settle!

    expect(hawk.zone).to be_nil
    expect(bears).to have_keyword(Magic::Cards::Keywords::INDESTRUCTIBLE)
  end
end
