require "spec_helper"

RSpec.describe Magic::Cards::Wellwisher do
  include_context "two player game"

  subject { ResolvePermanent("Wellwisher") }
  let(:activated_ability) { subject.activated_abilities.first }

  it "costs {1}{G}" do
    expect(Card("Wellwisher").cost.cost).to eq({ generic: 1, green: 1 })
  end

  context "activated ability" do
    it "gains life for its controller" do
      original_life = p1.life
      p1.activate_ability(ability: activated_ability)
      game.stack.resolve!
      game.tick!
      expect(p1.life).to eq(original_life + 1)

    end
  end
end
