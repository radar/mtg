module Magic
  module Cards
    class HerigastEruptingNullkite < Creature
      card_name "Herigast, Erupting Nullkite"
      cost generic: 9
      legendary_creature_type "Eldrazi Dragon"
      keywords :flying
      power 6
      toughness 6

      # Emerge {6}{R}{R}
      def alternative_cost = Costs::Mana.new(generic: 6, red: 2)

      def emerge_from = "Creature"

      # "Each creature spell you cast has emerge. The emerge cost is equal to its mana cost."
      class GrantEmerge < StaticAbility
        def grants_emerge?(card, player)
          card.creature? && player == controller
        end
      end

      def static_abilities = [GrantEmerge]

      # When you cast this spell, you may exile your hand. If you do, draw three cards.
      class ExileHandTrigger < TriggeredAbility::CastThisSpell
        class ExileHandChoice < Magic::Choice::May
          def resolve!
            controller.hand.cards.to_a.dup.each(&:exile!)
            draw_cards 3
          end
        end

        def call
          game.add_choice(ExileHandChoice.new(actor: actor))
        end
      end

      def cast_triggers = [ExileHandTrigger]
    end
  end
end
