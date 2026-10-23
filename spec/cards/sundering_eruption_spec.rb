# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SunderingEruption do
  include_context "two player game"

  let(:eruption) { Card("Sundering Eruption", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(eruption)
  end

  def cast_eruption(target)
    p1.add_mana(red: 3)
    p1.cast(card: eruption) do |action|
      action.pay_mana(generic: { red: 2 }, red: 1)
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a {2}{R} sorcery with a land back face" do
    expect(eruption.mana_value).to eq(3)
    expect(eruption).to be_sorcery
    expect(eruption.back_face.name).to eq("Volcanic Fissure")
    expect(eruption.back_face).to be_land
  end

  describe "the spell" do
    let!(:island) { ResolvePermanent("Island", owner: p2) }
    let!(:forest) { Card("Forest", owner: p2).tap { p2.library.add(_1) } }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "destroys target land" do
      cast_eruption(island)

      expect(p2.graveyard.cards.map(&:name)).to include("Island")
      expect(p2.lands.map(&:card)).not_to include(island)
    end

    it "lets the land's controller search for a basic land that enters tapped" do
      cast_eruption(island)
      choice = game.choices.last

      expect(choice.controller).to eq(p2)
      expect(choice.choices).to include(forest)

      game.resolve_choice!(targets: [forest])
      game.settle!

      expect(p2.lands.map(&:card)).to include(forest)
      expect(p2.lands.find { _1.card == forest }).to be_tapped
    end

    it "lets that player decline the search" do
      cast_eruption(island)
      game.skip_choice!
      game.settle!

      expect(p2.lands).to be_empty
    end

    it "can target your own land" do
      mine = ResolvePermanent("Mountain", owner: p1)
      p1.library.add(Card("Plains", owner: p1))
      cast_eruption(mine)

      expect(p1.graveyard.cards.map(&:name)).to include("Mountain")
      expect(game.choices.last.controller).to eq(p1)
    end

    it "stops creatures without flying from blocking this turn" do
      attacker = ResolvePermanent("Grizzly Bears", owner: p1)
      cast_eruption(island)
      game.skip_choice!

      expect(bears.can_block?(attacker)).to be(false)
    end

    it "lets creatures with flying block" do
      flyer = ResolvePermanent("Mistral Singer", owner: p2)
      attacker = ResolvePermanent("Grizzly Bears", owner: p1)
      cast_eruption(island)
      game.skip_choice!

      expect(flyer.can_block?(attacker)).to be(true)
    end

    it "also applies to creatures that enter later this turn" do
      attacker = ResolvePermanent("Grizzly Bears", owner: p1)
      cast_eruption(island)
      game.skip_choice!
      late_bears = ResolvePermanent("Grizzly Bears", owner: p2)
      late_flyer = ResolvePermanent("Mistral Singer", owner: p2)

      expect(late_bears.can_block?(attacker)).to be(false)
      expect(late_flyer.can_block?(attacker)).to be(true)
    end
  end

  describe "played as Volcanic Fissure" do
    let(:fissure) { p1.permanents.by_name("Volcanic Fissure").first }

    context "paying 3 life" do
      before { p1.play_land(land: eruption, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(fissure).to be_land
        expect(fissure).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {R}" do
        p1.activate_ability(ability: fissure.activated_abilities.first)
        expect(p1.mana_pool[:red]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: eruption, face: :back) }

      it "enters tapped, with no life lost" do
        expect(fissure).to be_tapped
        expect(p1.life).to eq(20)
      end
    end
  end
end
