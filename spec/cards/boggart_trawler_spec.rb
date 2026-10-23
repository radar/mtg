# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoggartTrawler do
  include_context "two player game"

  let(:trawler) { Card("Boggart Trawler", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(trawler)
  end

  it "is a {2}{B} 3/1 Goblin with a land back face" do
    expect(trawler.mana_value).to eq(3)
    expect(trawler).to be_creature
    expect(trawler.back_face.name).to eq("Boggart Bog")
    expect(trawler.back_face).to be_land
  end

  describe "enters the battlefield" do
    let!(:theirs) { Card("Forest", owner: p2).tap { p2.graveyard.add(_1) } }
    let!(:mine) { Card("Island", owner: p1).tap { p1.graveyard.add(_1) } }

    before do
      p1.add_mana(black: 3)
      p1.cast(card: trawler) { _1.pay_mana(generic: { black: 2 }, black: 1) }
      game.stack.resolve!
      game.settle!
    end

    it "is a 3/1" do
      permanent = p1.permanents.by_name("Boggart Trawler").first
      expect([permanent.power, permanent.toughness]).to eq([3, 1])
    end

    it "exiles target player's graveyard" do
      game.resolve_choice!(target: p2)

      expect(theirs.zone).to be_exile
      expect(p2.graveyard.cards).to be_empty
      expect(mine.zone).to be_graveyard
    end

    it "can target its controller's own graveyard" do
      game.resolve_choice!(target: p1)

      expect(mine.zone).to be_exile
      expect(theirs.zone).to be_graveyard
    end
  end

  describe "targeting a player with hexproof" do
    let!(:theirs) { Card("Forest", owner: p2).tap { p2.graveyard.add(_1) } }

    it "cannot exile that player's graveyard" do
      p2.gain_hexproof_until_end_of_turn!
      p1.add_mana(black: 3)
      p1.cast(card: trawler) { _1.pay_mana(generic: { black: 2 }, black: 1) }
      game.stack.resolve!
      game.settle!

      expect(theirs.zone).to be_graveyard
    end
  end

  describe "played as Boggart Bog" do
    let(:bog) { p1.permanents.by_name("Boggart Bog").first }

    context "paying 3 life" do
      before { p1.play_land(land: trawler, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(bog).to be_land
        expect(bog).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {B}" do
        p1.activate_ability(ability: bog.activated_abilities.first)
        expect(p1.mana_pool[:black]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: trawler, face: :back) }

      it "enters tapped, with no life lost" do
        expect(bog).to be_tapped
        expect(p1.life).to eq(20)
      end
    end
  end
end
