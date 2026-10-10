# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrievousWound do
  include_context "two player game"

  let(:wound) { Card("Grievous Wound", owner: p1) }

  before do
    go_to_main_phase!
    cast_and_resolve(card: wound, player: p1, targeting: p2)
    game.tick!
  end

  def wound_permanent
    game.battlefield.find { |permanent| permanent.name == "Grievous Wound" }
  end

  it "enchants target player" do
    expect(wound_permanent.attached_to).to eq(p2)
  end

  it "stops the enchanted player gaining life" do
    expect { p2.gain_life(5) }.not_to(change { p2.life })
  end

  it "lets other players gain life" do
    expect { p1.gain_life(5) }.to change { p1.life }.by(5)
  end

  it "makes the enchanted player lose half their life, rounded up, when dealt damage" do
    wound_permanent.trigger_effect(:deal_damage, target: p2, damage: 2)
    game.settle!
    expect(p2.life).to eq(9)
  end

  it "rounds up with an odd life total" do
    p2.lose_life(1)
    wound_permanent.trigger_effect(:deal_damage, target: p2, damage: 2)
    game.settle!
    expect(p2.life).to eq(8)
  end

  it "does nothing when another player is dealt damage" do
    wound_permanent.trigger_effect(:deal_damage, target: p1, damage: 3)
    game.settle!
    expect(p1.life).to eq(17)
  end
end
