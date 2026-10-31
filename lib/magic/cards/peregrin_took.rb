module Magic
  module Cards
    PeregrinTook = Creature("Peregrin Took") do
      cost generic: 2, green: 1
      legendary_creature_type "Halfling Citizen"
      power 2
      toughness 3
    end

    class PeregrinTook < Creature
      # "If one or more tokens would be created under your control, those tokens plus an additional Food token are
      # created instead."
      class ExtraFood < ReplacementEffect
        def applies?(effect)
          effect.controller == receiver.controller
        end

        def call(effect)
          Effects::Multiple.new(
            source: effect.source,
            effects: [
              effect,
              Effects::CreateToken.new(source: effect.source, controller: effect.controller, token_class: Tokens::Food)
            ]
          )
        end
      end

      def replacement_effects = { Effects::CreateToken => ExtraFood }

      # "Sacrifice three Foods: Draw a card."
      class SacrificeThreeFoods < Costs::Sacrifice
        def can_pay?(_player = nil) = choices.size >= 3

        def pay(payment:)
          payment = Array(payment)
          unless payment.uniq.size == 3 && payment.all? { choices.include?(_1) }
            raise "Sacrifice exactly three of: #{choices.map(&:name).join(', ')}"
          end

          payment.each(&:sacrifice!)
        end
      end

      class DrawAbility < Magic::ActivatedAbility
        def costs
          [SacrificeThreeFoods.new(source, source.controller.permanents.select { _1.type?("Food") })]
        end

        def resolve!
          draw_card
        end
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
