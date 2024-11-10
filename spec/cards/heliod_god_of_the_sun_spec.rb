require "spec_helper"

RSpec.describe Magic::Cards::HeliodGodOfTheSun do
  include_context "two player game"

  let!(:heliod) { ResolvePermanent("Heliod, God of The Sun") }

  it "is indestructible" do
    expect(heliod).to be_indestructible
  end

  context "devotion" do
    it "is not a creature" do
      expect(heliod).not_to be_creature
    end

    context "with 2x nine lives (4 pips) and itself" do
      before do
        2.times do
          ResolvePermanent("Nine Lives")
        end

        game.tick!
      end

      it "is a creature" do
        expect(heliod).to be_creature
      end
    end
  end

  context "vigilance static ability" do
    let(:wood_elves) { ResolvePermanent("Wood Elves") }

    it "grants vigilance to all creatures" do
      expect(wood_elves).to be_vigilant
      expect(heliod).not_to be_vigilant
    end
  end
end
