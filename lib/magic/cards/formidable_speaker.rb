module Magic
  module Cards
    FormidableSpeaker = Creature("Formidable Speaker") do
      cost generic: 2, green: 1
      creature_type("Elf Druid")
      power 2
      toughness 4
    end

    class FormidableSpeaker < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}, {T}"

        def target_choices
          (battlefield.permanents - [source])
        end

        def resolve!(target:)
          target.untap!
        end
      end

      def activated_abilities = [ActivatedAbility]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          # "If you do" (search only if a card was actually discarded): wrap the search in
          # the discard choice's own resolution rather than queuing both unconditionally.
          class DiscardChoice < Magic::Choice::Discard
            def initialize(actor:, player:)
              super(player: player)
              @actor = actor
            end

            def resolve!(card:)
              super
              game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :hand, enters_tapped: false, upto: 1, filter: Filter[:creatures], reveal: true))
            end
          end

          def resolve!
            game.choices.add(DiscardChoice.new(actor: actor, player: controller))
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
