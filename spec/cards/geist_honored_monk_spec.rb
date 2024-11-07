require 'spec_helper'

RSpec.describe Magic::Cards::GeistHonoredMonk do
  include_context "two player game"

  let!(:geist) { ResolvePermanent("Geist-Honored Monk", owner: p1) }

  context "power and toughness" do
    context "when it and its spirits are the only creature on the battlefield" do
      it "has power and toughness equal to creatures" do
        game.tick!

        expect(geist.power).to eq(3)
        expect(geist.toughness).to eq(3)
      end
    end

    context "when there are other creatures on the battlefield as well" do
      let!(:loxodon) { ResolvePermanent("Loxodon Wayfarer", owner: p1) }

      it "has power and toughness equal to creatures" do
        game.tick!

        expect(geist.power).to eq(4)
        expect(geist.toughness).to eq(4)
        expect(loxodon.power).to eq(1)
        expect(loxodon.toughness).to eq(5)
      end
    end

    context "when these another Geist-Honored Monk under this player's control" do
      let!(:geist_2) { ResolvePermanent("Geist-Honored Monk", owner: p1) }

      it "has power and toughness equal to creatures" do
        game.tick!

        expect(geist.power).to eq(6)
        expect(geist.toughness).to eq(6)
        expect(geist_2.power).to eq(6)
        expect(geist_2.toughness).to eq(6)
      end
    end

    it "ETB: creates two 1/1 white spirit creature tokens" do
      expect(p1.creatures.by_name("Spirit").count).to eq(2)
    end
  end
end
