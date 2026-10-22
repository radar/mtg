# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BridgeworksBattle do
  include_context "two player game"

  let(:battle) { Card("Bridgeworks Battle", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(battle)
  end

  def cast_battle(*targets)
    p1.add_mana(green: 3)
    p1.cast(card: battle) do |action|
      action.pay_mana(generic: { green: 2 }, green: 1)
      action.targeting(*targets)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a {2}{G} sorcery with a land back face" do
    expect(battle.mana_value).to eq(3)
    expect(battle).to be_sorcery
    expect(battle.back_face.name).to eq("Tanglespan Bridgeworks")
    expect(battle.back_face).to be_land
  end

  describe "the spell" do
    let!(:ogre) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:wall) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "gives the creature +2/+2 and fights the other creature" do
      cast_battle(bears, wall)

      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(bears.damage).to eq(2)
    end

    it "gives the bonus even when it fights nothing" do
      cast_battle(bears)

      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect(bears.damage).to eq(0)
      expect(p2.creatures.size).to eq(2)
    end

    it "only offers a creature you control first and creatures you don't control second" do
      mine, theirs = battle.target_choices

      expect(mine.to_a).to eq([bears])
      expect(theirs.to_a).to contain_exactly(ogre, wall)
    end
  end

  describe "played as Tanglespan Bridgeworks" do
    let(:bridgeworks) { p1.permanents.by_name("Tanglespan Bridgeworks").first }

    context "paying 3 life" do
      before { p1.play_land(land: battle, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(bridgeworks).to be_land
        expect(bridgeworks).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {G}" do
        p1.activate_ability(ability: bridgeworks.activated_abilities.first)
        expect(p1.mana_pool[:green]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: battle, face: :back) }

      it "enters tapped, with no life lost" do
        expect(bridgeworks).to be_tapped
        expect(p1.life).to eq(20)
      end
    end
  end
end
