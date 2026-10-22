# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HydroelectricSpecimen do
  include_context "two player game"

  let(:specimen) { Card("Hydroelectric Specimen", owner: p2) }
  let(:dart) { Card("Lava Dart", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(dart)
    p2.hand.add(specimen)
  end

  def cast_dart_at(target)
    p1.add_mana(red: 1)
    p1.cast(card: dart) do |action|
      action.pay_mana(red: 1)
      action.targeting(target)
    end
  end

  def flash_in_specimen
    p2.add_mana(blue: 3)
    p2.cast(card: specimen) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a {2}{U} 1/4 Weird with flash and a land back face" do
    expect(specimen.mana_value).to eq(3)
    expect(specimen).to be_creature
    expect(specimen.keywords).to include(Magic::Cards::Keywords::FLASH)
    expect(specimen.back_face.name).to eq("Hydroelectric Laboratory")
    expect(specimen.back_face).to be_land
  end

  it "is a 1/4" do
    flash_in_specimen
    permanent = p2.permanents.by_name("Hydroelectric Specimen").first

    expect([permanent.power, permanent.toughness]).to eq([1, 4])
  end

  describe "enters the battlefield" do
    it "can change the target of a spell with a single target to itself" do
      cast_dart_at(p2)
      flash_in_specimen
      game.resolve_choice!(target: game.stack.spells.last)
      game.settle!
      permanent = p2.permanents.by_name("Hydroelectric Specimen").first

      game.stack.resolve!
      game.settle!

      expect(p2.life).to eq(20)
      expect(permanent.damage).to eq(1)
    end

    it "lets the spell resolve unchanged when declined" do
      cast_dart_at(p2)
      flash_in_specimen
      game.skip_choice!
      game.settle!
      game.stack.resolve!
      game.settle!

      expect(p2.life).to eq(19)
    end

    it "does nothing when there is no spell on the stack" do
      flash_in_specimen

      expect(game.choices).to be_empty
    end
  end

  describe "played as Hydroelectric Laboratory" do
    let(:land_card) { Card("Hydroelectric Specimen", owner: p1) }
    let(:laboratory) { p1.permanents.by_name("Hydroelectric Laboratory").first }

    before { p1.hand.add(land_card) }

    context "paying 3 life" do
      before { p1.play_land(land: land_card, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(laboratory).to be_land
        expect(laboratory).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {U}" do
        p1.activate_ability(ability: laboratory.activated_abilities.first)
        expect(p1.mana_pool[:blue]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: land_card, face: :back) }

      it "enters tapped, with no life lost" do
        expect(laboratory).to be_tapped
        expect(p1.life).to eq(20)
      end
    end
  end
end
