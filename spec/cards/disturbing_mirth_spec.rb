# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DisturbingMirth do
  include_context "two player game"

  before { go_to_main_phase! }

  context "when it enters" do
    it "may sacrifice another creature to draw two cards" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      hand_size = p1.hand.cards.count
      ResolvePermanent("Disturbing Mirth", owner: p1)
      game.settle!
      game.resolve_choice!(sacrifice: bears)
      game.settle!

      expect(bears.zone).to be_nil
      expect(p1.hand.cards.count).to eq(hand_size + 2)
    end

    it "may sacrifice another enchantment" do
      sanctum = ResolvePermanent("Sanctum Of Calm Waters", owner: p1)
      game.settle!
      game.skip_choice! while game.choices.any?
      hand_size = p1.hand.cards.count
      ResolvePermanent("Disturbing Mirth", owner: p1)
      game.settle!
      game.resolve_choice!(sacrifice: sanctum)
      game.settle!

      expect(sanctum.zone).to be_nil
      expect(p1.hand.cards.count).to eq(hand_size + 2)
    end

    it "may decline" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      hand_size = p1.hand.cards.count
      ResolvePermanent("Disturbing Mirth", owner: p1)
      game.settle!
      game.skip_choice!

      expect(bears.zone).to be_battlefield
      expect(p1.hand.cards.count).to eq(hand_size)
    end

    it "offers no sacrifice when it is alone, since it must be another permanent" do
      ResolvePermanent("Disturbing Mirth", owner: p1)
      game.settle!

      expect(game.choices).to be_empty
    end

    it "can't sacrifice itself" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      mirth = ResolvePermanent("Disturbing Mirth", owner: p1)
      game.settle!

      expect(game.choices.last.candidates).not_to include(mirth)
    end
  end

  it "manifests dread when it is sacrificed" do
    mirth = ResolvePermanent("Disturbing Mirth", owner: p1)
    game.settle!
    mirth.sacrifice!
    game.settle!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.permanents.count(&:face_down?)).to eq(1)
    expect(mirth.zone).to be_nil
  end

  it "doesn't manifest dread when it is destroyed" do
    mirth = ResolvePermanent("Disturbing Mirth", owner: p1)
    game.settle!
    mirth.destroy!
    game.settle!

    expect(game.choices).to be_empty
  end
end
