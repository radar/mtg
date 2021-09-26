require 'spec_helper'

RSpec.describe Magic::Cards::GeistHonoredMonk do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }
  let(:geist) { described_class.new(controller: p1) }
  let(:loxodon) { Magic::Cards::LoxodonWayfarer.new(controller: p1) }

  before do
    allow(game).to receive(:battlefield) { battlefield }
  end

  context "power and toughness" do
    context "when it's the only creature on the battlefield" do
      let(:battlefield) { Magic::Battlefield.new(cards: [geist])}

      it "has power and toughness equal to creatures" do
        expect(geist.power).to eq(1)
        expect(geist.toughness).to eq(1)
      end
    end

    context "when there are other creatures on the battlefield" do
      let(:battlefield) { Magic::Battlefield.new(cards: [geist, loxodon])}
      before do
      end

      it "has power and toughness equal to creatures" do
        expect(geist.power).to eq(2)
        expect(geist.toughness).to eq(2)
      end
    end
  end
end
