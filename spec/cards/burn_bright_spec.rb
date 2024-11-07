require 'spec_helper'

RSpec.describe Magic::Cards::BurnBright do
  include_context "two player game"

  let!(:burn_bright) { Card("Burn Bright") }

  context "with 2 creature in play" do

    let!(:blood_glutton) { ResolvePermanent("Blood Glutton", owner: p1) }
    let!(:onakke_ogre) { ResolvePermanent("Onakke Ogre", owner: p1) }

    it "grants 2 power to both creatures " do
      p1.add_mana(red: 3)
      p1.cast(card: burn_bright) do
        _1.pay_mana(red: 1, generic: { red: 2 })
      end

      game.stack.resolve!
      game.tick!

      expect(onakke_ogre.power).to eq(6)
      expect(onakke_ogre.toughness).to eq(2)
      expect(blood_glutton.power).to eq(6)
      expect(blood_glutton.toughness).to eq(3)
    end
  end

  context "with 1 opposing creature in play" do

    let!(:onakke_ogre) { ResolvePermanent("Onakke Ogre", owner: p1) }
    let!(:cloudkin_seer) { ResolvePermanent("Cloudkin Seer", owner: p2) }

    it "does not buff opponent's creature" do
      p1.add_mana(red: 3)
      p1.cast(card: burn_bright) do
        _1.pay_mana(red: 1, generic: { red: 2 })
      end
      game.stack.resolve!
      game.tick!

      expect(cloudkin_seer.power).to eq(2)
      expect(onakke_ogre.power).to eq(6)
    end
  end
end
