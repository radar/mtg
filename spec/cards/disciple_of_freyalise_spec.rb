# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DiscipleOfFreyalise do
  include_context "two player game"

  let(:disciple) { Card("Disciple Of Freyalise", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(disciple)
  end

  def cast_disciple
    p1.add_mana(green: 6)
    p1.cast(card: disciple) { _1.pay_mana(generic: { green: 3 }, green: 3) }
    game.stack.resolve!
    game.settle!
  end

  it "is a {3}{G}{G}{G} 3/3 Elf Druid with a land back face" do
    expect(disciple.mana_value).to eq(6)
    expect(disciple).to be_creature
    expect(disciple.back_face.name).to eq("Garden of Freyalise")
    expect(disciple.back_face).to be_land
  end

  it "is a 3/3" do
    cast_disciple
    permanent = p1.permanents.by_name("Disciple of Freyalise").first

    expect([permanent.power, permanent.toughness]).to eq([3, 3])
  end

  describe "enters the battlefield" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before { p1.library.add(Card("Island", owner: p1)) }

    it "sacrifices the creature, gaining and drawing life equal to its power" do
      hand_size = p1.hand.count
      cast_disciple
      game.resolve_choice!(sacrifice: bears)
      game.settle!

      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(p1.life).to eq(22)
      expect(p1.hand.count).to eq(hand_size - 1 + 2)
    end

    it "does nothing when declined" do
      cast_disciple
      game.skip_choice!
      game.settle!

      expect(p1.creatures).to include(bears)
      expect(p1.life).to eq(20)
    end

  end

  it "does not offer itself and does nothing with no other creature" do
    cast_disciple

    expect(game.choices).to be_empty
    expect(p1.creatures.map(&:name)).to include("Disciple of Freyalise")
  end

  describe "played as Garden of Freyalise" do
    let(:garden) { p1.permanents.by_name("Garden of Freyalise").first }

    context "paying 3 life" do
      before { p1.play_land(land: disciple, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(garden).to be_land
        expect(garden).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {G}" do
        p1.activate_ability(ability: garden.activated_abilities.first)
        expect(p1.mana_pool[:green]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: disciple, face: :back) }

      it "enters tapped, with no life lost" do
        expect(garden).to be_tapped
        expect(p1.life).to eq(20)
      end
    end
  end
end
