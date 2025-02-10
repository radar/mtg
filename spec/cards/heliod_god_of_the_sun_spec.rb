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

  context "create a 2/1 white cleric enchantment creature token" do
    let(:create_cleric) { heliod.activated_abilities.first }

    it "can create a cleric token" do
      p1.add_mana(white: 4)
      p1.activate_ability(ability: create_cleric) do
        _1.pay_mana(white: 2, generic: { white: 2 })
      end

      game.stack.resolve!

      clerics = game.battlefield.creatures.by_name("Cleric")
      expect(clerics.count).to eq(1)
      cleric = clerics.first
      aggregate_failures do
        expect(cleric).to be_a_token
        expect(cleric).to be_an_enchantment
        expect(cleric.colors).to eq([:white])
        expect(cleric).to be_creature
        expect(cleric.power).to eq(2)
        expect(cleric.toughness).to eq(1)
      end
    end
  end
end
