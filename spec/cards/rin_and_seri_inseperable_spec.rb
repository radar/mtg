require "spec_helper"

RSpec.describe Magic::Cards::RinAndSeriInseperable do
  include_context "two player game"

  subject!(:permanent) { ResolvePermanent("Rin And Seri, Inseperable") }

  context "whenever you cast a dog spell" do
    it "creates a 1/1 green cat token" do
      p1.add_mana(red: 2)
      p1.cast(card: Card("Igneous Cur")) do
        _1.pay_mana(red: 1, generic: { red: 1 })
      end

      expect(creatures.count).to eq(2)
      cat = creatures.by_name("Cat").first
      expect(cat.power).to eq(1)
      expect(cat.toughness).to eq(1)
      expect(cat.colors).to eq([:green])
    end
  end

  context "whenever you cast a dog spell" do
    it "creates a 1/1 white cat token" do
      p1.add_mana(white: 4)
      p1.cast(card: Card("Healer Of The Pride")) do
        _1.pay_mana(white: 1, generic: { white: 3 })
      end

      expect(creatures.count).to eq(2)
      dog = creatures.by_name("Dog").first
      expect(dog.power).to eq(1)
      expect(dog.toughness).to eq(1)
      expect(dog.colors).to eq([:white])
    end
  end

  context "activated ability" do
    it "deals damage and gains life" do
      p1.add_mana(red: 1, green: 1, white: 1)
      ability = permanent.activated_abilities.first
      p1.activate_ability(ability: ability) do
        _1.targeting(p2)
        _1.pay_mana(red: 1, green: 1, white: 1)
      end

      game.tick!

      # One dog, one cat.
      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
    end
  end
end
