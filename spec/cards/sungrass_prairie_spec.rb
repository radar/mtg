require "spec_helper"

RSpec.describe Magic::Cards::SungrassPrairie do
  include_context "two player game"

  it "adds green and white mana for one generic mana" do
    prairie = ResolvePermanent("Sungrass Prairie", owner: p1)
    p1.add_mana(green: 1)
    p1.activate_ability(ability: prairie.activated_abilities.first) do |ability|
      ability.pay_mana(generic: { green: 1 })
    end

    expect(p1.mana_pool[:green]).to eq(1)
    expect(p1.mana_pool[:white]).to eq(1)
  end
end