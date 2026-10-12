module Magic
  module Cards
    TectonicGiant = Creature("Tectonic Giant") do
      cost generic: 2, red: 2
      creature_type "Elemental Giant"
      power 3
      toughness 4
    end

    class TectonicGiant < Creature
      # "Exile the top two cards of your library. Choose one of them. Until the end of your next turn, you may play that
      # card." The other card stays exiled.
      class PickCardChoice < Magic::Choice::Targeted
        attr_reader :choices

        def initialize(actor:, cards:)
          @choices = cards
          super(actor: actor)
        end

        def prompt = "Choose one of the exiled cards. You may play it until the end of your next turn."

        def choice_amount = 1

        def resolve!(target:)
          game.play_permissions.grant_until_end_of_next_turn(card: target, player: controller)
        end
      end

      class ModeChoice < Magic::Choice
        DAMAGE = :damage
        EXILE = :exile

        def modes = { DAMAGE => "Deals 3 damage to each opponent", EXILE => "Exile the top two cards of your library. Choose one of them. Until the end of your next turn, you may play that card" }

        def resolve!(mode:)
          case mode
          when DAMAGE
            game.opponents(controller).each { trigger_effect(:deal_damage, source: actor, target: _1, damage: 3) }
          when EXILE
            cards = controller.library.cards.first(2)
            cards.each(&:exile!)
            game.add_choice(PickCardChoice.new(actor: actor, cards: cards)) if cards.any?
          else
            raise ArgumentError, "unknown mode #{mode.inspect}"
          end
        end
      end

      # "Whenever this creature attacks ..."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call = game.add_choice(ModeChoice.new(actor: actor))
      end

      # "... or becomes the target of a spell an opponent controls, choose one --"
      class TargetedTrigger < TriggeredAbility::SpellCast
        def should_perform? = opponents.include?(event.player) && event.targets.include?(actor)

        def call = game.add_choice(ModeChoice.new(actor: actor))
      end

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger, Events::SpellCast => TargetedTrigger }
    end
  end
end
