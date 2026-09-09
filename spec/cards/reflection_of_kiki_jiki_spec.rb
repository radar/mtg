require "spec_helper"

RSpec.describe Magic::Cards::ReflectionOfKikiJiki do
  include_context "two player game"

  it "copies a nonlegendary creature with haste" do
    reflection = ResolvePermanent("Reflection of Kiki-Jiki", owner: p1)
    target = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(generic: 1)
    p1.activate_ability(ability: reflection.activated_abilities.first) do |ability|
      ability.targeting(target)
      ability.pay_mana(generic: { generic: 1 })
    end
    game.stack.resolve!
    game.tick!

    copy = p1.creatures.by_name("Grizzly Bears").find(&:token?)
    expect(copy).not_to be_nil
    expect(copy.has_keyword?(:haste)).to be(true)
  end
end