# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StumpStomp do
  include_context "two player game"

  let(:stomp) { Card("Stump Stomp", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:their_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(stomp)
  end

  def cast_stomp(*targets)
    p1.add_mana(red: 2)
    p1.cast(card: stomp) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.targeting(*targets)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a {1}{R/G} sorcery with a land back face" do
    expect(stomp.mana_value).to eq(2)
    expect(stomp).to be_sorcery
    expect(stomp.back_face.name).to eq("Burnwillow Clearing")
    expect(stomp.back_face).to be_land
  end

  describe "the spell" do
    it "has your creature deal damage equal to its power to their creature" do
      cast_stomp(bears, their_bears)

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "does not damage your creature in return" do
      cast_stomp(bears, their_bears)

      expect(bears.damage).to eq(0)
    end

    it "can damage a planeswalker you don't control" do
      basri = ResolvePermanent("Basri Ket", owner: p2)
      loyalty = basri.loyalty
      cast_stomp(bears, basri)

      expect(basri.loyalty).to eq(loyalty - 2)
    end

    it "only offers your creatures first and their creatures or planeswalkers second" do
      basri = ResolvePermanent("Basri Ket", owner: p2)
      mine, theirs = stomp.target_choices

      expect(mine.to_a).to eq([bears])
      expect(theirs.to_a).to contain_exactly(their_bears, basri)
    end
  end

  describe "played as Burnwillow Clearing" do
    let(:clearing) { p1.permanents.by_name("Burnwillow Clearing").first }

    before { p1.play_land(land: stomp, face: :back) }

    it "enters tapped" do
      expect(clearing).to be_land
      expect(clearing).to be_tapped
    end

    it "taps for {R}" do
      clearing.untap!
      p1.activate_ability(ability: clearing.activated_abilities.first) { _1.choose(:red) }
      expect(p1.mana_pool[:red]).to eq(1)
    end

    it "taps for {G}" do
      clearing.untap!
      p1.activate_ability(ability: clearing.activated_abilities.first) { _1.choose(:green) }
      expect(p1.mana_pool[:green]).to eq(1)
    end
  end
end
