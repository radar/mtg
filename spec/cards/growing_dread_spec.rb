# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrowingDread do
  include_context "two player game"

  before { go_to_main_phase! }

  it "has flash and manifests dread when it enters" do
    dread = ResolvePermanent("Growing Dread", owner: p1)
    game.settle!

    expect(dread.card).to have_keyword(:flash)
    game.resolve_choice!(target: game.choices.last.choices.first)
    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  context "with the enchantment in play" do
    before do
      ResolvePermanent("Growing Dread", owner: p1)
      game.settle!
      game.skip_choice! while game.choices.any?
    end

    def manifest(owner, card)
      owner.library.add(card)
      game.manifest!(card, controller: owner)
    end

    it "puts a +1/+1 counter on a permanent you turn face up" do
      bears = manifest(p1, Card("Grizzly Bears", owner: p1))
      p1.add_mana(green: 2)
      p1.turn_face_up(permanent: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.settle!

      expect(bears.name).to eq("Grizzly Bears")
      expect([bears.power, bears.toughness]).to eq([3, 3])
    end

    it "doesn't trigger for the opponent turning a permanent face up" do
      bears = manifest(p2, Card("Grizzly Bears", owner: p2))
      game.next_turn
      go_to_main_phase!
      p2.add_mana(green: 2)
      p2.turn_face_up(permanent: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.settle!

      expect([bears.power, bears.toughness]).to eq([2, 2])
    end
  end
end
