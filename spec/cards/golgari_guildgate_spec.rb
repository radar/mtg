require 'spec_helper'

RSpec.describe Magic::Cards::GolgariGuildgate do
  include_context "two player game"

  let(:card) { described_class.new(game: game) }

  let!(:permanent) do
    action = Magic::Actions::PlayLand.new(player: p1, card: card)
    game.take_action(action)
    p1.permanents.by_name("Golgari Guildgate").first
  end

  it "enters the battlefield tapped" do
    game.stack.resolve!
    expect(permanent).to be_tapped
  end

  it "taps for either black or green" do
    action = Magic::Actions::ActivateAbility.new(player: p1, permanent: permanent, ability: card.activated_abilities.first)
    action.pay_tap
    game.take_action(action)
    game.resolve_pending_effect(black: 1)
    expect(game.effects).to be_empty
    expect(p1.mana_pool[:black]).to eq(1)
  end
end
