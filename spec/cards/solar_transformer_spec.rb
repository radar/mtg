# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SolarTransformer do
  include_context "two player game"

  let!(:transformer) { ResolvePermanent("Solar Transformer", owner: p1) }

  def colorless_ability = transformer.activated_abilities.first

  def any_color_ability = transformer.activated_abilities.last

  it "enters tapped" do
    expect(transformer).to be_tapped
  end

  it "gives you three energy when it enters" do
    expect(p1.energy).to eq(3)
  end

  context "when untapped" do
    before { transformer.untap! }

    it "taps for {C}" do
      p1.activate_ability(ability: colorless_ability)

      expect(p1.mana_pool[:colorless]).to eq(1)
      expect(p1.energy).to eq(3)
      expect(transformer).to be_tapped
    end

    it "taps and pays {E} for one mana of any color" do
      p1.activate_ability(ability: any_color_ability) { |a| a.choose(:red) }

      expect(p1.mana_pool[:red]).to eq(1)
      expect(p1.energy).to eq(2)
      expect(transformer).to be_tapped
    end

    it "can't make coloured mana without energy" do
      p1.pay_energy!(3)

      expect { p1.activate_ability(ability: any_color_ability) { |a| a.choose(:red) } }
        .to raise_error(RuntimeError, /can't pay 1 \{E\}/)
      expect(p1.mana_pool[:red]).to eq(0)
    end
  end
end
