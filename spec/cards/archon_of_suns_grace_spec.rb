require 'spec_helper'

RSpec.describe Magic::Cards::ArchonOfSunsGrace do
  include_context "two player game"

  subject { ResolvePermanent("Archon of Sun's Grace") }

  it "has flying" do
    expect(subject).to have_keyword(:flying)
  end

  it "has lifelink" do
    expect(subject).to have_keyword(:lifelink)
  end

  context "grants pegasi lifelink" do
    let(:pegasus) { described_class::PegasusToken.new(game: game, owner: p1).resolve!}
    context "if archon is on the battlefield" do
      before do
        subject
      end

      it "has lifelink" do
        expect(pegasus).to have_keyword(:lifelink)
      end
    end

    context "if archon is not on the battlefield" do
      it "does not have lifelink" do
        expect(pegasus).not_to have_keyword(:lifelink)
      end
    end
  end

  context "whenever an enchantment enters the battlefield" do
    before do
      subject
    end

    it "... under your control, create a pegasus" do
      p1.add_mana(white: 3)
      p1.cast(card: Card("Nine Lives")) do
        _1.pay_mana(generic: { white: 1 }, white: 2)
      end

      game.stack.resolve!

      pegasus = creatures.by_name("Pegasus").first
      expect(pegasus).not_to be_nil
      expect(pegasus.power).to eq(2)
      expect(pegasus.toughness).to eq(2)
      expect(pegasus).to have_keyword(:flying)
      # Pegasus gains lifelink because Archon is on the battlefield
      expect(pegasus).to have_keyword(:lifelink)
    end
  end
end
