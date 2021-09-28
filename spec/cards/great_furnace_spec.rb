require 'spec_helper'

RSpec.describe Magic::Cards::GreatFurnace do
  let(:controller) { Magic::Player.new }
  subject { described_class.new(controller: controller) }

  it "taps for red mana" do
    expect(controller).to receive(:add_mana).with(red: 1)
    subject.tap!
  end

  it "is an artifact" do
    expect(subject).to be_an_artifact
  end
end
