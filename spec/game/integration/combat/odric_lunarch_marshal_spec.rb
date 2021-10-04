require 'spec_helper'

RSpec.describe Magic::Game, "combat -- first striker and Odric" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:battlefield_raptor) { Card("Battlefield Raptor", controller: p1) }
  let(:odric) { Card("Odric, Lunarch Marshal", controller: p1) }

  before do
    game.battlefield.add(battlefield_raptor)
    game.battlefield.add(odric)
  end

  context "when in combat" do
    before do
      subject.go_to_beginning_of_combat!
    end

    it "odric gains flying and first strike from battlefield raptor" do
      expect(subject).to be_at_step(:beginning_of_combat)
      expect(odric.flying?).to eq(true)
      expect(odric.first_strike?).to eq(true)
    end
  end
end
