# frozen_string_literal: true

require "spec_helper"

# Also the reference spec for spell // land modal double-faced cards (docs/patterns/mechanics.md).
RSpec.describe Magic::Cards::RevitalizingRepast do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:repast) { Card("Revitalizing Repast", owner: p1) }

  before do
    p1.hand.items.clear
    p1.hand.add(repast)
  end

  it "has the front face's characteristics in hand and a land back face with no cost" do
    expect(repast.name).to eq("Revitalizing Repast")
    expect(repast).to be_instant
    expect(repast).not_to be_land
    expect(repast.mana_value).to eq(1)
    expect(repast).to be_double_faced
    expect(repast.back_face.name).to eq("Old-Growth Grove")
    expect(repast.back_face).to be_land
    expect(repast.back_face.mana_value).to eq(1)
  end

  context "cast as the front face" do
    before do
      p1.add_mana(green: 1)
      p1.cast(card: repast) { |a| a.pay_mana(green: 1).targeting(bears) }
      game.stack.resolve!
      game.tick!
    end

    it "puts a +1/+1 counter on the creature" do
      expect(bears.power).to eq(3)
    end

    it "gives it indestructible until end of turn" do
      expect(bears.has_keyword?(Magic::Cards::Keywords::INDESTRUCTIBLE)).to eq(true)
      current_turn.end!
      current_turn.cleanup!
      game.tick!
      expect(bears.has_keyword?(Magic::Cards::Keywords::INDESTRUCTIBLE)).to eq(false)
    end

    it "does not use the land drop" do
      expect(p1.can_play_lands?).to eq(true)
    end
  end

  context "played as the back face" do
    before { p1.play_land(land: repast, face: :back) }

    let(:grove) { p1.permanents.by_name("Old-Growth Grove").first }

    it "enters as an Old-Growth Grove land, tapped, using the land drop" do
      expect(grove).not_to be_nil
      expect(grove).to be_land
      expect(grove).not_to be_instant
      expect(grove).to be_tapped
      expect(p1.permanents.by_name("Revitalizing Repast")).to be_empty
      expect(p1.can_play_lands?).to eq(false)
      expect(p1.hand.cards).not_to include(repast)
    end

    it "taps for {B} or {G}" do
      grove.untap!
      p1.activate_ability(ability: grove.activated_abilities.first) { _1.choose(:black) }
      expect(p1.mana_pool[:black]).to eq(1)
    end
  end

  it "offers both casting the front and playing the back as legal actions" do
    p1.add_mana(green: 1)
    actions = game.legal_actions(p1)

    expect(actions.grep(Magic::Actions::Cast).map { _1.card }).to include(repast)
    plays = actions.grep(Magic::Actions::PlayLand)
    expect(plays.map(&:card)).to eq([repast])
    expect(plays.map(&:face)).to eq([:back])
  end

  it "offers no land play once the land drop is used" do
    p1.play_land(land: Card("Forest", owner: p1).tap { p1.hand.add(_1) })
    expect(game.legal_actions(p1).grep(Magic::Actions::PlayLand)).to be_empty
  end
end
