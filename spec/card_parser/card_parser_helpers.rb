# frozen_string_literal: true

# Generates a card from plain card text and evals it into Magic::Cards,
# replacing any card of the same name, so specs can play generated cards.
module CardParserHelpers
  def generate(text)
    Magic::CardGenerator.generate(Magic::CardParser.parse(text))
  end

  def load_card(text)
    result = Magic::CardParser.parse(text)
    const = Magic::CardGenerator.const_name(result.name)
    Magic::Cards.send(:remove_const, const) if Magic::Cards.const_defined?(const, false)
    TOPLEVEL_BINDING.eval(Magic::CardGenerator.generate(result))
    Magic::Cards.const_get(const)
  end
end
