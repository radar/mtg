module Magic
  module Cards
    SkemfarShadowsage = Creature("Skemfar Shadowsage") do
      cost generic: 3, black: 1
      creature_type "Elf Cleric"
      power 2
      toughness 5
    end

    class SkemfarShadowsage < Creature
      # "When this creature enters, choose one — Each opponent loses X life, where X is the greatest
      # number of creatures you control that have a creature type in common. / You gain X life, ..."
      class ModeChoice < Magic::Choice
        DRAIN = :drain
        GAIN = :gain

        def resolve!(mode:)
          raise ArgumentError, "unknown mode #{mode.inspect}" unless [DRAIN, GAIN].include?(mode)

          x = greatest_shared_type_count
          if mode == DRAIN
            game.opponents(controller).each { |opponent| trigger_effect(:lose_life, target: opponent, life: x) }
          else
            trigger_effect(:gain_life, target: controller, life: x)
          end
        end

        private

        def greatest_shared_type_count
          creatures = controller.creatures
          Magic::Types::Creatures.values.map { |type| creatures.count { _1.type?(type) } }.max || 0
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
