require 'spec_helper'

RSpec.describe Magic::Cards::BaneslayerAngel do
  let(:game) { Magic::Game.new }
   subject { Card("Baneslayer Angel") }

  it "has keywords" do
    expect(subject.flying?).to eq(true)
    expect(subject.first_strike?).to eq(true)
    expect(subject.lifelink?).to eq(true)
  end

  it "has protection from dragons" do
    dragon = Card("Hellkite Punisher")
    expect(subject).to be_protected_from(dragon)
  end

  it "has protection from demons" do
    demon = Card("Renegade Demon")
    expect(subject).to be_protected_from(demon)
  end
end
