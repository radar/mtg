# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FellTheProfane do
  include_context "two player game"

  let(:fell) { Card("Fell The Profane", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(fell)
  end

  it "is a {2}{B}{B} instant with a land back face" do
    expect(fell.mana_value).to eq(4)
    expect(fell).to be_instant
    expect(fell.back_face.name).to eq("Fell Mire")
    expect(fell.back_face).to be_land
  end

  describe "Fell the Profane" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    def cast!(target)
      p1.add_mana(black: 4)
      action = cast_action(player: p1, card: fell)
      action.pay_mana(generic: { black: 2 }, black: 2)
      action.targeting(target)
      game.take_action(action)
      game.stack.resolve!
      game.settle!
    end

    it "destroys target creature" do
      cast!(bears)
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "destroys target planeswalker" do
      walker = ResolvePermanent("Basri Ket", owner: p2)
      cast!(walker)
      expect(p2.graveyard.cards.map(&:name)).to include("Basri Ket")
    end

    it "targets only creatures and planeswalkers" do
      ResolvePermanent("Sol Ring", owner: p2)
      walker = ResolvePermanent("Basri Ket", owner: p2)
      expect(fell.target_choices).to contain_exactly(bears, walker)
    end
  end

  describe "played as Fell Mire" do
    let(:mire) { p1.permanents.by_name("Fell Mire").first }

    context "paying 3 life" do
      before { p1.play_land(land: fell, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(mire).to be_land
        expect(mire).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {B}" do
        p1.activate_ability(ability: mire.activated_abilities.first)
        expect(p1.mana_pool[:black]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: fell, face: :back) }

      it "enters tapped, with no life lost" do
        expect(mire).to be_tapped
        expect(p1.life).to eq(20)
      end
    end

    context "with 2 life" do
      before do
        p1.lose_life(18)
        p1.play_land(land: fell, face: :back, pay_life: true)
      end

      it "cannot pay 3 life, so it enters tapped" do
        expect(mire).to be_tapped
        expect(p1.life).to eq(2)
      end
    end

    it "is offered both ways as a legal action" do
      plays = game.legal_actions(p1).select { _1.is_a?(Magic::Actions::PlayLand) && _1.card == fell }
      expect(plays.map(&:pay_life?)).to contain_exactly(false, true)
    end
  end
end
