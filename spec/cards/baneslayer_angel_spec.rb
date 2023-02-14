require 'spec_helper'

RSpec.describe Magic::Cards::BaneslayerAngel do
  include_context "two player game"

  subject { Permanent("Baneslayer Angel", owner: p1) }

  it "has keywords" do
    expect(subject.flying?).to eq(true)
    expect(subject.first_strike?).to eq(true)
    expect(subject.lifelink?).to eq(true)
  end

  it "has protection from dragons" do
    dragon = Permanent("Hellkite Punisher", owner: p2)
    expect(subject).to be_protected_from(dragon)
  end

  it "has protection from demons" do
    demon = Permanent("Renegade Demon", owner: p2)
    expect(subject).to be_protected_from(demon)
  end
end
