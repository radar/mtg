require 'spec_helper'

RSpec.describe Magic::Cards::ValorousSteed do
  include_context "two player game"

  subject(:valorous_steed) { ResolvePermanent("Valorous Steed", owner: p1) }

  before do
    game.battlefield.add(subject)
  end

  it "has vigilance" do
    expect(subject).to be_vigilant
  end

  context "when it enters the battlefield" do
    it "creates a 2/2 white Knight with vigilance" do
      subject
      knight = creatures.by_name("Knight").controlled_by(p1).first
      expect(knight).not_to be_nil
      expect(knight).to be_vigilant
    end
  end
end
