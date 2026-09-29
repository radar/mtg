# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Sacrifice ~ unless you pay {W}{W}." / "Tap ~ unless you pay 2 life." /
      # "Sacrifice ~ unless you discard a card." / "Sacrifice ~ unless you sacrifice a
      # creature." A player choice (Choice::UnlessPay): declining, or not being able to
      # pay, applies the penalty. The effects after it run when the choice resolves.
      class UnlessPay < Data.define(:penalty, :mana, :life, :discard, :sacrifice_type)
        include Effect

        LINE = /\A(?<penalty>sacrifice|tap) ~ unless you (?:pay (?<mana>(?:\{[^}]+\})+)|pay (?<life>\d+) life|(?<discard>discard a card)|sacrifice an? (?<type>[a-z-]+))\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(penalty: m[:penalty].downcase.to_sym, mana: m[:mana], life: m[:life]&.to_i, discard: !m[:discard].nil?,
              sacrifice_type: m[:type]&.capitalize)
        end

        def choice_base = "Magic::Choice::UnlessPay"
        def choice_class_name = "UnlessPayChoice"

        def choice_args
          args = ["penalty: #{penalty.inspect}"]
          args << "mana: #{mana.inspect}" if mana
          args << "life: #{life}" if life
          args << "discard: true" if discard
          args << "sacrifice_type: #{sacrifice_type.inspect}" if sacrifice_type
          args
        end
      end
    end
  end
end
