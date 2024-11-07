require 'spec_helper'

RSpec.describe Magic::Cards::Shock do
  include_context "two player game"

  let!(:shock) { Card("Shock") }
  let!(:cloudkin_seer) { ResolvePermanent("Cloudkin Seer", owner: p2) }
  let(:basri_ket) { ResolvePermanent("Basri Ket", owner: p2) }

  it "destroys the Cloudkin Seer" do
    p1.add_mana(red: 1)
    p1.cast(card: shock) do
      _1.pay_mana(red: 1).targeting(cloudkin_seer)
    end
    game.stack.resolve!
    expect(cloudkin_seer).to be_dead
  end

  it "targets the opponent" do
    p2_life_total = p2.life
    p1.add_mana(red: 1)
    p1.cast(card: shock) do
      _1.pay_mana(red: 1).targeting(p2)
    end
    game.stack.resolve!
    expect(p2.life).to eq(p2_life_total - 2)
  end

  it "removes planeswalker loyalty" do
    p1.add_mana(red: 1)
    p1.cast(card: shock) do
      _1.pay_mana(red: 1).targeting(basri_ket)
    end
    game.stack.resolve!
    expect(basri_ket.loyalty).to eq(1)
  end
end
