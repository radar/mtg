module Magic
  module Cards
    UtopiaSprawl = Aura("Utopia Sprawl") do
      cost green: 1
    end

    class UtopiaSprawl < Aura
      class ColorChoice < Magic::Choice
        COLORS = %i[white blue black red green]
        attr_reader :choices

        def initialize(actor:)
          @choices = COLORS
          super
        end

        def resolve!(color:)
          raise "Invalid color chosen for Utopia Sprawl" unless choices.include?(color)

          actor.card.chosen_color = color
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ColorChoice.new(actor: actor))
        end
      end

      class ManaAddition < StaticAbility
        def additional_mana(land, _mana)
          return unless land == @source.attached_to

          controller.add_mana(@source.card.chosen_color => 1)
        end
      end

      def target_choices
        battlefield.controlled_by(controller).lands.by_any_type("Forest")
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [ManaAddition]
    end
  end
end