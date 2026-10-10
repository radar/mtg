# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Glimmerlight do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "creates a 1/1 white Glimmer enchantment creature token when it enters" do
    ResolvePermanent("Glimmerlight", owner: p1)

    glimmers = p1.creatures.select { _1.type?("Glimmer") }
    expect(glimmers.size).to eq(1)
    expect([glimmers.first.power, glimmers.first.toughness]).to eq([1, 1])
    expect(glimmers.first.enchantment?).to be(true)
  end

  it "gives equipped creature +1/+1 for equip {1}" do
    glimmerlight = ResolvePermanent("Glimmerlight", owner: p1)
    p1.add_mana(colorless: 1)
    p1.activate_ability(ability: glimmerlight.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { colorless: 1 })
    end
    game.stack.resolve!
    game.tick!

    expect(bears.attachments).to include(glimmerlight)
    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(3)
  end
end
