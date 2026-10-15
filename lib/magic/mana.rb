module Magic
  class Mana
    COLORS = %i[white blue black red green]
    # What a cost can name directly: {C} is paid only with colorless mana, never with a colour.
    COST_SYMBOLS = (COLORS + [:colorless]).freeze
  end
end
