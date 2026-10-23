# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShadowOfTheSecondSun do
  include_context "two player game"

  before { go_to_main_phase! }

  def enchant(player)
    cast_and_resolve(card: Card("Shadow Of The Second Sun", owner: p1), player: p1, targeting: player)
  end

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "enchants target player" do
    enchant(p1)
    shadow = game.battlefield.find { _1.name == "Shadow of the Second Sun" }
    expect(shadow.attached_to).to eq(p1)
  end

  it "adds an untap, upkeep and draw step after the enchanted player's postcombat main phase" do
    enchant(p1)
    to_second_main!
    hand = p1.hand.count

    current_turn.advance_step!
    expect(current_turn.step).to eq("untap")
    current_turn.advance_step!
    expect(current_turn.step).to eq("upkeep")
    current_turn.advance_step!
    expect(current_turn.step).to eq("draw")
    expect(p1.hand.count).to eq(hand + 1)
    current_turn.advance_step!
    expect(current_turn.step).to eq("end")
  end

  it "untaps the active player's permanents in the added untap step" do
    enchant(p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.tap!
    to_second_main!
    current_turn.advance_step!
    expect(bears).not_to be_tapped
  end

  it "does nothing for a different player's postcombat main phase" do
    enchant(p2)
    to_second_main!
    current_turn.advance_step!
    expect(current_turn.step).to eq("end")
  end

  it "adds the phase only once per postcombat main phase" do
    enchant(p1)
    to_second_main!
    4.times { current_turn.advance_step! }
    expect(current_turn.step).to eq("end")
    current_turn.advance_step!
    expect(current_turn.step).to eq("cleanup")
  end
end
