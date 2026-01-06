# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Magic::Cards::DreamsOfLaguna do
  include_context "two player game"

  let(:dreams_of_laguna) { Card("Dreams of Laguna") }

  def p1_library
    [
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      # End initial card draw
      Card("Mountain"),
      Card("Island"),
      Card("Plains"),
      Card("Swamp"),
      Card("Sol Ring"),
    ]
  end

  context "casting from hand" do
    it "surveils 1 then draws a card (keeping card on top)" do
      top_card = p1.library.first
      p1.add_mana(blue: 2)
      p1.cast(card: dreams_of_laguna) do
        _1.pay_mana(generic: { blue: 1 }, blue: 1)
      end
      game.stack.resolve!

      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::DreamsOfLaguna::SurveilChoice)

      game.resolve_choice!(top: [top_card])

      expect(dreams_of_laguna.zone).to be_graveyard
      # After keeping Mountain on top and drawing it, next card is Island
      expect(p1.library.first.name).to eq("Island")
      expect(p1.hand.map(&:name)).to include("Mountain")
    end

    it "surveils 1 then draws a card (putting card in graveyard)" do
      top_card = p1.library.first
      p1.add_mana(blue: 2)
      p1.cast(card: dreams_of_laguna) do
        _1.pay_mana(generic: { blue: 1 }, blue: 1)
      end
      game.stack.resolve!

      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::DreamsOfLaguna::SurveilChoice)

      game.resolve_choice!(graveyard: [top_card])

      expect(dreams_of_laguna.zone).to be_graveyard
      # Mountain went to graveyard, drew Island
      expect(p1.graveyard.map(&:name)).to include("Mountain")
      expect(p1.hand.map(&:name)).to include("Island")
      expect(p1.library.first.name).to eq("Plains")
    end
  end

  context "flashback from graveyard" do
    before do
      dreams_of_laguna.move_to_graveyard!(p1)
    end

    it "can be exiled after casting with flashback" do
      # Simplified test - just verify that flashback flag causes exile
      # The full flashback flow would require more complex setup
      
      # Manually create a cast action with flashback flag
      p1.add_mana(blue: 4)
      action = Magic::Actions::Cast.new(
        card: dreams_of_laguna,
        player: p1,
        game: game,
        flashback: true
      )
      action.mana_cost = dreams_of_laguna.flashback_cost
      action.pay_mana(generic: { blue: 3 }, blue: 1)
      
      game.stack.add(action)
      game.stack.resolve!

      # Resolve the surveil choice
      top_card = p1.library.first
      choice = game.choices.last
      game.resolve_choice!(top: [top_card])

      # Card should be exiled, not in graveyard
      expect(dreams_of_laguna.zone).to be_exile
      expect(p1.graveyard.by_name("Dreams of Laguna")).to be_empty
    end
  end
end
