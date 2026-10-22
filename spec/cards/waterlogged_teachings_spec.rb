# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WaterloggedTeachings do
  include_context "two player game"

  let(:teachings) { Card("Waterlogged Teachings", owner: p1) }
  let!(:opt) { Card("Opt", owner: p1).tap { p1.library.add(_1) } }
  let!(:specimen) { Card("Hydroelectric Specimen", owner: p1).tap { p1.library.add(_1) } }
  let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } }
  let!(:sorcery) { Card("Bridgeworks Battle", owner: p1).tap { p1.library.add(_1) } }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(teachings)
  end

  it "is a {3}{U/B} instant with a land back face" do
    expect(teachings.mana_value).to eq(4)
    expect(teachings).to be_instant
    expect(teachings.back_face.name).to eq("Inundated Archive")
    expect(teachings.back_face).to be_land
  end

  describe "the spell" do
    before do
      p1.add_mana(blue: 4)
      p1.cast(card: teachings) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1) }
      game.stack.resolve!
      game.settle!
    end

    it "offers instant cards and cards with flash only" do
      expect(game.choices.last.choices.to_a).to contain_exactly(opt, specimen)
    end

    it "puts an instant into your hand" do
      game.resolve_choice!(targets: [opt])
      game.settle!

      expect(p1.hand).to include(opt)
    end

    it "puts a card with flash into your hand" do
      game.resolve_choice!(targets: [specimen])
      game.settle!

      expect(p1.hand).to include(specimen)
    end
  end

  describe "played as Inundated Archive" do
    let(:archive) { p1.permanents.by_name("Inundated Archive").first }

    before { p1.play_land(land: teachings, face: :back) }

    it "enters tapped" do
      expect(archive).to be_land
      expect(archive).to be_tapped
    end

    it "taps for {U}" do
      archive.untap!
      p1.activate_ability(ability: archive.activated_abilities.first) { _1.choose(:blue) }
      expect(p1.mana_pool[:blue]).to eq(1)
    end

    it "taps for {B}" do
      archive.untap!
      p1.activate_ability(ability: archive.activated_abilities.first) { _1.choose(:black) }
      expect(p1.mana_pool[:black]).to eq(1)
    end
  end
end
