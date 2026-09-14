# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CurseOfThePiercedHeart do
  include_context "two player game"

  let(:curse) { Card("Curse Of The Pierced Heart", owner: p1) }

  def curse_permanent
    game.battlefield.find { |permanent| permanent.name == "Curse of the Pierced Heart" }
  end

  it "enchants target player" do
    cast_and_resolve(card: curse, player: p1, targeting: p2)

    expect(curse_permanent.attached_to).to eq(p2)
    expect(p2.attachments).to include(curse_permanent)
  end

  it "deals 1 damage to the enchanted player at the beginning of their upkeep" do
    cast_and_resolve(card: curse, player: p1, targeting: p2)

    expect {
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
    }.to change { p2.life }.by(-1)
  end

  it "does not trigger on a different player's upkeep" do
    cast_and_resolve(card: curse, player: p1, targeting: p2)

    expect {
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
    }.not_to change { p1.life }
  end

  it "lets the curse's controller choose a planeswalker the enchanted player controls instead" do
    cast_and_resolve(card: curse, player: p1, targeting: p2)
    planeswalker = ResolvePermanent("Basri Ket", owner: p2)

    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
    game.resolve_choice!(target: planeswalker)

    expect(planeswalker.loyalty).to eq(2)
    expect(p2.life).to eq(20)
  end
end
