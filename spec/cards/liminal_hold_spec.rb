# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LiminalHold do
  include_context "two player game"

  context "with a nonland permanent an opponent controls" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:hold) { ResolvePermanent("Liminal Hold", owner: p1) }

    it "offers only nonland permanents an opponent controls" do
      ResolvePermanent("Forest", owner: p2)
      own = ResolvePermanent("Wood Elves", owner: p1)
      choices = game.choices.last.choices
      expect(choices).to include(bears)
      expect(choices).not_to include(own)
      expect(choices.map(&:name)).not_to include("Forest")
    end

    it "exiles the target and gains 2 life" do
      expect { game.resolve_choice!(target: bears) }.to change { p1.life }.by(2)
      expect(bears.card.zone).to be_exile
      expect(game.battlefield.permanents).not_to include(bears)
    end

    it "returns the card under its owner's control when Liminal Hold leaves the battlefield" do
      game.resolve_choice!(target: bears)
      hold.destroy!

      returned = game.battlefield.creatures.by_name("Grizzly Bears").first
      expect(returned).not_to be_nil
      expect(returned.controller).to eq(p2)
      expect(bears.card.zone).to be_battlefield
    end

    it "still gains 2 life when nothing is exiled" do
      expect { game.skip_choice! }.to change { p1.life }.by(2)
      expect(bears.zone).to be_battlefield
    end
  end

  it "gains 2 life with no target at all" do
    expect { ResolvePermanent("Liminal Hold", owner: p1) }.to change { p1.life }.by(2)
    expect(game.choices).to be_empty
  end
end
