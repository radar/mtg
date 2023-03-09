require 'spec_helper'

RSpec.describe Magic::Cards::Shock do
  include_context "two player game"

  let!(:shock) { described_class.new(game: game) }
  let!(:cloudkin_seer) { ResolvePermanent("Cloudkin Seer", owner: p2) }
  let(:basri_ket) { ResolvePermanent("Basri Ket", owner: p2) }

  it "destroys the Cloudkin Seer" do
    p1.add_mana(red: 1)
    action = Magic::Actions::Cast.new(player: p1, card: shock)
        .pay_mana(red: 1)
        .targeting(cloudkin_seer)
    game.take_action(action)
    game.tick!
    expect(cloudkin_seer).to be_dead
  end

  it "targets the opponent" do
    p2_life_total = p2.life
    p1.add_mana(red: 1)
    action = Magic::Actions::Cast.new(player: p1, card: shock)
      .pay_mana(red: 1)
      .targeting(p2)
    game.take_action(action)
    game.tick!
    expect(p2.life).to eq(p2_life_total - 2)
  end

  
end
