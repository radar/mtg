# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OsseousSticktwister do
  include_context "two player game"

  let!(:twister) { ResolvePermanent("Osseous Sticktwister", owner: p1) }

  def fill_graveyard
    ["Wood Elves", "Sol Ring", "Glorious Anthem", "Island"].each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  def go_to_end_step
    go_to_main_phase!
    current_turn.end!
    game.settle!
  end

  it "is a 2/2 artifact creature with lifelink" do
    expect(twister.power).to eq(2)
    expect(twister.toughness).to eq(2)
    expect(twister).to be_artifact
    expect(twister).to be_lifelink
  end

  it "does nothing at end step without delirium" do
    go_to_end_step
    expect(game.choices).to be_empty
    expect(p2.life).to eq(20)
  end

  context "with delirium" do
    before { fill_graveyard }

    it "lets the opponent discard a card to avoid damage" do
      go_to_end_step
      card = p2.hand.cards.first
      game.resolve_choice!(card: card)
      game.settle!
      expect(card.zone).to eq(p2.graveyard)
      expect(p2.life).to eq(20)
    end

    it "lets the opponent sacrifice a nonland permanent to avoid damage" do
      bear = ResolvePermanent("Grizzly Bears", owner: p2)
      go_to_end_step
      game.resolve_choice!(permanent: bear)
      game.settle!
      expect(p2.graveyard.cards).to include(bear.card)
      expect(p2.life).to eq(20)
    end

    it "deals damage equal to its power if the opponent declines" do
      go_to_end_step
      game.skip_choice!
      game.settle!
      expect(p2.life).to eq(18)
    end

    it "deals damage straight away if the opponent has nothing to give" do
      p2.hand.cards.dup.each(&:discard!)
      go_to_end_step
      game.settle!
      game.stack.resolve!
      expect(p2.hand.cards).to be_empty
      expect(p2.life).to eq(18)
    end
  end
end
