# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Lembas do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_lembas
    card = Card("Lembas", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { green: 2 }) }
    game.stack.resolve!
    game.settle!
    card
  end

  it "is a Food artifact costing {2}" do
    card = Card("Lembas")
    expect(card.type?("Artifact")).to be(true)
    expect(card.type?("Food")).to be(true)
    expect(card.cost.to_s).to include("2")
  end

  context "when it enters" do
    it "scries 1 then draws a card (scry to bottom)" do
      top = p1.library.first
      second = p1.library.first(2).last
      card = cast_lembas
      expect(game.choices.last).to be_a(Magic::Cards::Lembas::ScryChoice)
      hand = p1.hand.count

      game.resolve_choice!(bottom: [top])
      game.settle!

      expect(p1.hand.count).to eq(hand + 1)
      expect(p1.hand).to include(second)
      expect(p1.hand).not_to include(top)
      expect(p1.library.last).to eq(top)
      expect(card.zone).to be_battlefield
    end

    it "draws the card kept on top when kept on top" do
      top = p1.library.first
      cast_lembas
      hand = p1.hand.count

      game.resolve_choice!(top: [top])
      game.settle!

      expect(p1.hand.count).to eq(hand + 1)
      expect(p1.hand).to include(top)
    end

    it "still draws when the scry is declined" do
      top = p1.library.first
      cast_lembas
      hand = p1.hand.count

      game.skip_choice!
      game.settle!

      expect(p1.hand.count).to eq(hand + 1)
      expect(p1.hand).to include(top)
    end
  end

  context "{2}, {T}, Sacrifice: gain 3 life" do
    let!(:lembas) do
      ResolvePermanent("Lembas", owner: p1).tap do
        game.settle!
        game.skip_choice! if game.choices.any?
        game.settle!
      end
    end

    it "gains 3 life for the controller" do
      p1.add_mana(green: 2)
      p1.activate_ability(ability: lembas.activated_abilities.first) { |a| a.pay_mana(generic: { green: 2 }) }
      game.stack.resolve!
      game.settle!

      expect(p1.life).to eq(23)
      expect(p2.life).to eq(20)
    end

    it "does not gain life without paying" do
      expect { p1.activate_ability(ability: lembas.activated_abilities.first) { |_| } }.to raise_error(StandardError)
      expect(p1.life).to eq(20)
    end
  end

  context "when put into a graveyard from the battlefield" do
    it "is shuffled into its owner's library" do
      card = cast_lembas
      game.skip_choice!
      game.settle!
      lembas = p1.permanents.find { _1.name == "Lembas" }
      library_size = p1.library.count

      lembas.destroy!
      game.settle!

      expect(card.zone).to be_library
      expect(p1.library.count).to eq(library_size + 1)
      expect(p1.graveyard.cards.map(&:name)).not_to include("Lembas")
    end

    it "is shuffled after being sacrificed for life" do
      card = cast_lembas
      game.skip_choice!
      game.settle!
      lembas = p1.permanents.find { _1.name == "Lembas" }
      p1.add_mana(green: 2)
      p1.activate_ability(ability: lembas.activated_abilities.first) { |a| a.pay_mana(generic: { green: 2 }) }
      game.stack.resolve!
      game.settle!

      expect(p1.life).to eq(23)
      expect(card.zone).to be_library
    end

    it "is not shuffled when it goes to the graveyard from elsewhere" do
      card = Card("Lembas", owner: p1)
      p1.hand.add(card)
      card.move_zone!(to: p1.graveyard)
      game.settle!

      expect(card.zone).to be_graveyard
    end
  end
end
