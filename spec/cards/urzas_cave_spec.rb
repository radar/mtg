# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UrzasCave do
  include_context "two player game"

  let!(:cave) { ResolvePermanent("Urza's Cave", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: cave.activated_abilities.first)

    expect(cave).to be_tapped
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  context "search ability" do
    let(:forest) { Card("Forest", owner: p1) }
    let(:bears) { Card("Grizzly Bears", owner: p1) }

    before do
      p1.library.add(bears)
      p1.library.add(forest)
    end

    def activate
      p1.add_mana(colorless: 3)
      p1.activate_ability(ability: cave.activated_abilities.last) { |a| a.pay_mana(generic: { colorless: 3 }) }
    end

    it "sacrifices itself to put a land onto the battlefield tapped" do
      activate
      expect(p1.graveyard.by_name("Urza's Cave").count).to eq(1)
      game.stack.resolve!

      choice = game.choices.last
      expect(choice.choices).to include(forest)
      expect(choice.choices).not_to include(bears)
      game.resolve_choice!(targets: [forest])

      land = game.battlefield.permanents.by_name("Forest").first
      expect(land).to be_tapped
      expect(p1.library).not_to include(forest)
    end

    it "can't be activated without {3}" do
      p1.add_mana(colorless: 2)
      expect do
        p1.activate_ability(ability: cave.activated_abilities.last) { |a| a.pay_mana(generic: { colorless: 2 }) }
      end.to raise_error(StandardError)
    end
  end
end
