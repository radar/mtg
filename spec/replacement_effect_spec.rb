require 'spec_helper'

RSpec.describe Magic::ReplacementEffect do
  DummyContext = Struct.new(:effect)

  let(:context) { DummyContext.new(Object.new) }

  describe '#applies_with_context?' do
    it 'raises when applies? does not return a boolean' do
      klass = Class.new(described_class) do
        def applies?(_effect)
          :maybe
        end

        def call(effect)
          effect
        end
      end

      replacement = klass.new(receiver: Object.new)

      expect {
        replacement.applies_with_context?(context)
      }.to raise_error(Magic::ReplacementEffect::InvalidApplicabilityResult)
    end
  end

  describe '#call_with_context' do
    it 'raises when call does not return an effect-like object' do
      klass = Class.new(described_class) do
        def applies?(_effect)
          true
        end

        def call(_effect)
          Object.new
        end
      end

      replacement = klass.new(receiver: Object.new)

      expect {
        replacement.call_with_context(context)
      }.to raise_error(Magic::ReplacementEffect::InvalidReplacementResult)
    end
  end

  describe 'base interface' do
    it 'raises NotImplementedError for applies?' do
      replacement = described_class.new(receiver: Object.new)

      expect {
        replacement.applies?(Object.new)
      }.to raise_error(NotImplementedError)
    end

    it 'raises NotImplementedError for call' do
      replacement = described_class.new(receiver: Object.new)

      expect {
        replacement.call(Object.new)
      }.to raise_error(NotImplementedError)
    end
  end
end
