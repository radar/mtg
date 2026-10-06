require "spec_helper"

RSpec.describe Magic::Cards::DemonOfFatesDesign do
  include_context "two player game"

  let!(:demon) { ResolvePermanent("Demon of Fate's Design", owner: p1) }

  it "is an enchantment creature with flying and trample" do
    expect(demon).to be_creature
    expect(demon).to be_enchantment
    expect(demon).to be_flying
    expect(demon).to be_trample
  end

  describe "casting an enchantment by paying life" do
    before { go_to_main_phase! }

    let(:first) { Card("Sanctum Of Calm Waters", owner: p1) }
    let(:second) { Card("Sanctum Of Calm Waters", owner: p1) }

    it "pays life equal to its mana value instead of mana, once each turn" do
      p1.hand.add(first)
      p1.hand.add(second)

      expect { p1.cast(card: first, pay_life: true) }.to change(p1, :life).by(-first.mana_value)
      game.stack.resolve!

      expect(Magic::Actions::Cast.new(game: game, player: p1, card: second, pay_life: true).pays_life_instead?).to be(false)
    end

    it "is not offered for a card that is not an enchantment" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)

      expect(Magic::Actions::Cast.new(game: game, player: p1, card: bears).may_pay_life?).to be(false)
    end
  end

  describe "the sacrifice ability" do
    it "gives +X/+0, where X is the sacrificed enchantment's mana value" do
      sanctum = ResolvePermanent("Sanctum Of Calm Waters", owner: p1)
      p1.add_mana(black: 3)

      p1.activate_ability(ability: demon.activated_abilities.first) do |action|
        action.pay_mana(generic: { black: 2 }, black: 1)
        action.pay_sacrifice(sanctum)
      end
      game.settle!

      expect(demon.power).to eq(6 + sanctum.mana_value)
      expect(game.battlefield.permanents).not_to include(sanctum)
    end

    it "cannot sacrifice itself" do
      expect(demon.activated_abilities.first.costs.last.choices).not_to include(demon)
    end
  end
end
