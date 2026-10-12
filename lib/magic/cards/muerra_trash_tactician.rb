module Magic
  module Cards
    MuerraTrashTactician = Creature("Muerra, Trash Tactician") do
      legendary_creature_type "Raccoon Warrior"
      cost red: 1, green: 1, generic: 1
      power 2
      toughness 4
    end

    class MuerraTrashTactician < Creature
      # At the beginning of your first main phase, add {R} or {G} for each Raccoon you control.
      class MainPhaseTrigger < TriggeredAbility
        class ColorsChoice < Magic::Choice
          def initialize(actor:, amount:)
            super(actor: actor)
            @amount = amount
          end

          def choices = %i[red green]

          def resolve!(colors:)
            raise ArgumentError, "choose #{@amount} colors" unless colors.size == @amount && (colors - choices).empty?

            colors.each { |color| controller.add_mana(color => 1) }
          end
        end

        def should_perform? = event.active_player == controller

        def call
          raccoons = battlefield.controlled_by(controller).creatures.count { _1.type?("Raccoon") }
          game.choices.add(ColorsChoice.new(actor: actor, amount: raccoons)) if raccoons.positive?
        end
      end

      # Whenever you expend 4, you gain 3 life.
      class ExpendFour < TriggeredAbility::Expend
        def threshold = 4

        def call
          trigger_effect(:gain_life, life: 3)
        end
      end

      # Whenever you expend 8, exile the top two cards of your library. Until the end of your next turn, you may
      # play those cards.
      class ExpendEight < TriggeredAbility::Expend
        def threshold = 8

        def call
          controller.library.first(2).each do |card|
            trigger_effect(:exile, target: card)
            game.play_permissions.grant_until_end_of_next_turn(card: card, player: controller)
          end
        end
      end

      def event_handlers
        super.merge(Events::FirstMainPhase => MainPhaseTrigger, Events::ManaSpent => [ExpendFour, ExpendEight])
      end
    end
  end
end
