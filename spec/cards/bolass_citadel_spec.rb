require "spec_helper"

RSpec.describe Magic::Cards::BolassCitadel do
  include_context "two player game"

  let!(:citadel) { ResolvePermanent("Bolas's Citadel", owner: p1) }

  it "is a legendary artifact" do
    expect(citadel).to be_artifact
    expect(citadel).to be_legendary
  end

  it "reveals the top card of its controller's library only" do
    ability = game.battlefield.static_abilities.find { |a| a.respond_to?(:reveals_top_card?) }
    expect(ability.reveals_top_card?(p1)).to eq(true)
    expect(ability.reveals_top_card?(p2)).to eq(false)
  end

  it "casts the top card for life equal to its mana value" do
    go_to_main_phase!
    card = Card("Grizzly Bears", owner: p1)
    p1.library.add(card)
    p1.library.cards.unshift(p1.library.cards.delete(card)) if p1.library.first != card
    expect(p1.library.first).to eq(card)

    action = Magic::Actions::Cast.new(game: game, player: p1, card: card)
    expect(action.illegal_reason).to be_nil
    expect { game.take_action(action) }.to change(p1, :life).by(-2)
  end

  it "makes each opponent lose 10 life by sacrificing ten nonland permanents" do
    others = Array.new(10) { ResolvePermanent("Grizzly Bears", owner: p1) }
    action = Magic::Actions::ActivateAbility.new(game: game, player: p1, ability: citadel.activated_abilities.first)
    action.pay(:self_tap)
    action.pay_sacrifice(others)
    game.take_action(action)
    game.stack.resolve!
    expect(p2.life).to eq(10)
  end
end
