# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ForagingWickermaw do
  include_context "two player game"

  it "is a colorless 1/3 artifact creature Scarecrow" do
    wickermaw = ResolvePermanent("Foraging Wickermaw", owner: p1)
    expect([wickermaw.power, wickermaw.toughness]).to eq([1, 3])
    expect(wickermaw).to be_artifact
    expect(wickermaw).to be_type("Scarecrow")
    expect(wickermaw).to be_colorless
  end

  it "surveils 1 when it enters" do
    ResolvePermanent("Foraging Wickermaw", owner: p1)
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(1)
  end

  context "mana ability" do
    let!(:wickermaw) { ResolvePermanent("Foraging Wickermaw", owner: p1) }
    let(:ability) { wickermaw.activated_abilities.first }

    before { game.skip_choice! }

    def activate(color)
      p1.add_mana(green: 1)
      p1.activate_ability(ability:) do
        _1.pay_mana(generic: { green: 1 })
        _1.choose(color)
      end
      game.stack.resolve!
    end

    it "adds one mana of any color and becomes that color until end of turn" do
      activate(:blue)

      expect(p1.mana_pool[:blue]).to eq(1)
      expect(wickermaw.colors).to eq([:blue])

      go_to_main_phase!
      current_turn.end!
      current_turn.cleanup!
      expect(wickermaw).to be_colorless
    end

    it "can be activated only once each turn" do
      activate(:red)

      p1.add_mana(green: 1)
      expect { p1.activate_ability(ability:) { _1.pay_mana(generic: { green: 1 }) } }.to raise_error(Magic::IllegalAction)
    end

    it "can be activated again next turn" do
      activate(:red)
      go_to_main_phase!
      current_turn.end!
      current_turn.cleanup!
      game.next_turn

      activate(:white)
      expect(wickermaw.colors).to eq([:white])
    end
  end
end
