require "spec_helper"

RSpec.describe Magic::Cards::UtopiaSprawl do
  include_context "two player game"

  it "adds the chosen color when the enchanted Forest is tapped" do
    forest = ResolvePermanent("Forest", owner: p1)
    aura = Card("Utopia Sprawl", owner: p1)
    p1.hand.add(aura)
    p1.add_mana(green: 1)
    p1.cast(card: aura) do |action|
      action.targeting(forest)
      action.pay_mana(green: 1)
    end
    game.stack.resolve!
    game.resolve_choice!(color: :red)

    p1.activate_ability(ability: forest.activated_abilities.first)

    expect(p1.mana_pool[:red]).to eq(1)
  end
end