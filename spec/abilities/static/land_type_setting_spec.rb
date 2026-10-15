# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Abilities::Static::LandTypeSetting do
  include_context "two player game"

  # "Nonbasic lands are Swamps." -- a stand-in source so the engine piece is tested without a real card.
  let(:swamp_setting) do
    Class.new(described_class) do
      sets_land_type Magic::Types::Lands::Swamp

      def applicable_targets = battlefield.lands.reject(&:basic_land?)
    end
  end

  let(:source_class) do
    setting = swamp_setting
    Class.new(Magic::Cards::HarbingerOfTheSeas) do
      define_method(:static_abilities) { [setting] }
    end
  end

  def put_source
    Magic::Permanent.put_onto_battlefield(game: game, card: source_class.new(game: game, owner: p1))
  end

  let!(:cave) { ResolvePermanent("Urzas Cave", owner: p2) }

  context "while the source is on the battlefield" do
    before do
      go_to_main_phase!
      put_source
      game.settle!
    end

    it "replaces the land's subtypes with the basic type" do
      expect(cave.type?(Magic::Types::Lands::Swamp)).to eq(true)
      expect(cave.type?("Swamp")).to eq(true)
      expect(cave.land?).to eq(true)
    end

    it "removes subtypes the land had before" do
      gate = ResolvePermanent("Selesnya Guildgate", owner: p2)
      game.settle!
      expect(gate.types).to eq([Magic::Types::Land, Magic::Types::Lands::Swamp])
      expect(gate.type?(Magic::Types::Lands::Gate)).to eq(false)
    end

    it "gives the land the basic type's mana ability and removes its own abilities" do
      abilities = cave.activated_abilities
      expect(abilities.map(&:class)).to eq([Magic::Types::Lands::Swamp::ManaAbility])
    end

    it "lets the land tap for the new colour" do
      p2.activate_ability(ability: cave.activated_abilities.first)
      expect(cave).to be_tapped
      expect(p2.mana_pool[:black]).to eq(1)
      expect(p2.mana_pool[:colorless]).to eq(0)
    end

    it "does not affect basic lands" do
      mountain = ResolvePermanent("Mountain", owner: p1)
      game.settle!
      expect(mountain.type?("Swamp")).to eq(false)
      expect(mountain.type?("Mountain")).to eq(true)
    end
  end
end
