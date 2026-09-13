# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::DevilishValet do
  include_context "two player game"

  subject(:devilish_valet) { ResolvePermanent("Devilish Valet", owner: p1) }

  it "is a 1/3 with trample and haste" do
    expect(devilish_valet.power).to eq(1)
    expect(devilish_valet.toughness).to eq(3)
    expect(devilish_valet).to be_trample
    expect(devilish_valet.has_keyword?(:haste)).to eq(true)
  end

  context "when another creature you control enters" do
    it "doubles this creature's power until end of turn" do
      devilish_valet

      ResolvePermanent("Wood Elves", owner: p1)
      game.tick!

      expect(devilish_valet.power).to eq(2)
    end

    it "doubles again for each subsequent creature entering that turn" do
      devilish_valet

      ResolvePermanent("Wood Elves", owner: p1)
      game.tick!
      ResolvePermanent("Alpine Watchdog", owner: p1)
      game.tick!

      expect(devilish_valet.power).to eq(4)
    end
  end

  context "when this creature enters" do
    it "does not trigger off its own entry" do
      devilish_valet

      expect(devilish_valet.power).to eq(1)
    end
  end

  context "when an opponent's creature enters" do
    it "does not double this creature's power" do
      devilish_valet

      ResolvePermanent("Wood Elves", owner: p2)
      game.tick!

      expect(devilish_valet.power).to eq(1)
    end
  end
end
