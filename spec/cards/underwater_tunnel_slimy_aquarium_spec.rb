# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnderwaterTunnelSlimyAquarium do
  include_context "two player game"

  before { go_to_main_phase! }

  def unlock(room, side, mana)
    p1.add_mana(**mana)
    p1.unlock_door(permanent: room, door: side) { _1.auto_pay }
    game.settle!
  end

  it "Underwater Tunnel surveils 2 when unlocked" do
    room = ResolvePermanent("Underwater Tunnel Slimy Aquarium", doors: [:right])
    unlock(room, :left, blue: 1)

    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
    expect(game.choices.last.amount).to eq(2)
  end

  it "Slimy Aquarium manifests dread, then puts a +1/+1 counter on that creature" do
    room = ResolvePermanent("Underwater Tunnel Slimy Aquarium", doors: [:left])
    unlock(room, :right, blue: 4)
    game.resolve_choice!(target: game.choices.last.choices.first)
    game.settle!

    manifested = p1.permanents.find(&:face_down?)
    expect([manifested.power, manifested.toughness]).to eq([3, 3])
  end
end
