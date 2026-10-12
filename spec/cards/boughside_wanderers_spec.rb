# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoughsideWanderers do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 4/4 Elf Scout" do
    wanderers = ResolvePermanent("Boughside Wanderers", owner: p1)

    expect([wanderers.power, wanderers.toughness]).to eq([4, 4])
    expect(wanderers.card.types).to include("Elf", "Scout")
  end

  context "when it enters" do
    let(:bears) { Card("Grizzly Bears", owner: p1) }
    let(:shock) { Card("Shock", owner: p1) }

    before do
      p1.library.add(shock)
      p1.library.add(bears)
      ResolvePermanent("Boughside Wanderers", owner: p1)
    end

    it "lets you put a permanent card from the top four into your hand" do
      game.resolve_choice!(target: bears)

      expect(bears.zone).to be_hand
    end

    it "doesn't offer instants or sorceries, and puts the rest on the bottom" do
      choice = game.choices.first
      expect(choice.choices).to include(bears)
      expect(choice.choices).not_to include(shock)
      game.resolve_choice!(target: bears)

      expect(shock.zone).to be_library
      expect(p1.library.last(3)).to include(shock)
    end

    it "lets you take nothing" do
      game.resolve_choice!(target: nil)

      expect(bears.zone).to be_library
      expect(p1.library.last(4)).to include(bears)
    end
  end

  it "gets +2/+2 until end of turn when a land enters under your control" do
    wanderers = ResolvePermanent("Boughside Wanderers", owner: p1)
    game.skip_choice! if game.choices.any?
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    game.tick!

    expect([wanderers.power, wanderers.toughness]).to eq([6, 6])
  end
end
