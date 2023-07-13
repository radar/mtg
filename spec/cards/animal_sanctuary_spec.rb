require "spec_helper"

RSpec.describe Magic::Cards::AnimalSanctuary do
  include_context "two player game"

  subject! { ResolvePermanent("Animal Sanctuary", owner: p1) }


  context "mana ability" do
    def activate_ability
      action = Magic::Actions::ActivateAbility.new(permanent: subject, ability: subject.activated_abilities.first, player: p1)
      game.take_action(action)
    end

    it "adds one colorless mana" do
      activate_ability
      expect(p1.mana_pool[:colorless]).to eq(1)
    end
  end

  context "counter ability" do
    before do
      ResolvePermanent("Wild Jhovall", owner: p1)
      ResolvePermanent("Rambunctious Mutt", owner: p1)
    end

    def activate_ability
      p1.add_mana(green: 2)
      action = Magic::Actions::ActivateAbility.new(permanent: subject, ability: subject.activated_abilities.last, player: p1)
      action.pay_mana(colorless: { green: 2 })
      game.take_action(action)
      game.stack.resolve!
    end

    it "puts a +1/+1 counter on target creature" do
      activate_ability
      effect = game.effects.first
      expect(effect).to be_a(Magic::Effects::AddCounter)
      rambunctious_mutt = game.battlefield.creatures.by_name("Rambunctious Mutt").first
      game.resolve_pending_effect(rambunctious_mutt)
      expect(rambunctious_mutt.power).to eq(3)
      expect(rambunctious_mutt.toughness).to eq(3)
    end
  end
end
