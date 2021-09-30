require 'spec_helper'

require 'spec_helper'

RSpec.describe Magic::Cards::GloriousAnthem do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:glorious_anthem) { Card("Glorious Anthem", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p1) }

  context "when wood elves is already on the field" do
    before do
      game.battlefield.add(wood_elves)
    end

    context "entering the battlefield adds a static ability" do
      it "adds a creatures get buffed ability" do
        glorious_anthem.entered_the_battlefield!
        ability = game.battlefield.static_abilities.first
        expect(ability).to be_a(Magic::Abilities::Static::CreaturesGetBuffed)
        expect(wood_elves.power).to eq(2)
        expect(wood_elves.toughness).to eq(2)
      end
    end
  end

  context "when glorious anthem is already on the battlefield" do
    before do
      game.battlefield.add(glorious_anthem)
      glorious_anthem.entered_the_battlefield!
    end

    context "a creature from the same controller enters the battlefield" do
      it "creature gets buffed" do
        game.battlefield.add(wood_elves)
        wood_elves.entered_the_battlefield!
        expect(wood_elves.power).to eq(2)
        expect(wood_elves.toughness).to eq(2)
      end
    end

    context "a creature from the same controller enters the battlefield" do
      it "creature gets buffed" do
        game.battlefield.add(wood_elves)
        wood_elves.entered_the_battlefield!
        expect(wood_elves.power).to eq(2)
        expect(wood_elves.toughness).to eq(2)
      end
    end
  end

  context "when this card's ability exists" do
    before do
      glorious_anthem.entered_the_battlefield!
    end

    context "leaving the battlefield" do
      it "clears the static ability" do
        glorious_anthem.left_the_battlefield!
        expect(game.battlefield.static_abilities.count).to eq(0)
      end
    end
  end
end
