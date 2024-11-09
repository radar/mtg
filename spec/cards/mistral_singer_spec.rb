require 'spec_helper'

RSpec.describe Magic::Cards::MistralSinger do
  include_context "two player game"

  subject! { ResolvePermanent("Mistral Singer", owner: p2) }

  context 'base card atrributes' do
    it "is a siren" do
      expect(subject.card.types).to include("Siren")
      expect(subject.card.types).to include("Creature")
    end

    it "Has flying" do
      expect(subject.flying?).to eq(true)
    end

    it "has an unmodified power + toughness" do
      expect(subject.power).to eq(2)
      expect(subject.toughness).to eq(2)
    end
  end

  context "when a non-creature spell has been cast" do
    before do
      p2.add_mana(white: 1, blue: 1)
      action = cast_action(player: p2, card: Card("Revitalize", owner: p2))
        .pay_mana(white: 1, generic: { blue: 1 })
        .perform
      game.tick!
    end

    it "has a boosted power + toughness" do
      expect(subject.power).to eq(3)
      expect(subject.toughness).to eq(3)
      expect(subject.modifiers).to all(be_until_eot)
    end
  end

  context "when a creature spell has been cast" do
    before do
      p2.add_mana(red: 2, black: 1)
      action = cast_action(player: p2, card: Card("Onakke Ogre"))
        .pay_mana(red: 1, generic: { red: 1, black: 1 })
        .perform
      game.tick!
    end

    it "has a regular power and toughness" do
      expect(subject.power).to eq(2)
      expect(subject.toughness).to eq(2)
    end
  end

end
