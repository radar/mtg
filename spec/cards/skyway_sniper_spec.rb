require "spec_helper"

RSpec.describe Magic::Cards::SkywaySniper do
  include_context "two player game"

  let(:skyway_sniper) { ResolvePermanent("Skyway Sniper") }
  let!(:aven_gagglemaster) { ResolvePermanent("Aven Gagglemaster", owner: p2) }

  it "has reach" do
    expect(skyway_sniper).to have_keyword(:reach)
  end

  context "activated ability" do
    it "deals 1 damage to target creature with flying" do
      p1.add_mana(green: 3)
      p1.activate_ability(ability: skyway_sniper.activated_abilities.first) do
        _1.pay_mana(green: 1, generic: { green: 2 })
        _1.targeting(aven_gagglemaster)
      end

      game.tick!

      expect(aven_gagglemaster.damage).to eq(1)
    end
  end
end
