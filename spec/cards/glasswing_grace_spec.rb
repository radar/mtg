# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlasswingGrace do
  include_context "two player game"

  let(:grace) { Card("Glasswing Grace", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(grace)
  end

  it "is a {3}{W/B}{W/B} Aura with a land back face" do
    expect(grace.mana_value).to eq(5)
    expect(grace.back_face.name).to eq("Age-Graced Chapel")
    expect(grace.back_face).to be_land
  end

  describe "cast as the Aura" do
    before do
      p1.add_mana(white: 5)
      p1.cast(card: grace) { |a| a.pay_mana(generic: { white: 3 }, white: 2).targeting(bears) }
      game.stack.resolve!
      game.settle!
    end

    it "gives the enchanted creature +2/+2" do
      expect([bears.power, bears.toughness]).to eq([4, 4])
    end

    it "gives the enchanted creature flying and lifelink" do
      expect(bears).to be_flying
      expect(bears).to be_lifelink
    end
  end

  describe "played as Age-Graced Chapel" do
    let(:chapel) { p1.permanents.by_name("Age-Graced Chapel").first }

    before { p1.play_land(land: grace, face: :back) }

    it "enters tapped" do
      expect(chapel).to be_land
      expect(chapel).to be_tapped
    end

    it "taps for {W}" do
      chapel.untap!
      p1.activate_ability(ability: chapel.activated_abilities.first) { _1.choose(:white) }
      expect(p1.mana_pool[:white]).to eq(1)
    end

    it "taps for {B}" do
      chapel.untap!
      p1.activate_ability(ability: chapel.activated_abilities.first) { _1.choose(:black) }
      expect(p1.mana_pool[:black]).to eq(1)
    end
  end
end
