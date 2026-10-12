module Magic
  module Cards
    class StormchasersTalent < ClassEnchantment
      card_name "Stormchaser's Talent"
      cost blue: 1
      level_costs 2 => "{3}{U}", 3 => "{5}{U}"

      # When this Class enters, create a 1/1 blue and red Otter creature token with prowess.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Otter)
        end
      end

      def etb_triggers = [EntersTrigger]

      # Level 2: When this Class becomes level 2, return target instant or sorcery card from your
      # graveyard to your hand.
      class LevelTwoTrigger < TriggeredAbility
        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.select { _1.instant? || _1.sorcery? }

          def choice_amount = 1

          def resolve!(target:)
            target.move_to_hand!
          end
        end

        def should_perform? = event.permanent == actor && event.level == 2

        def call
          choice = ReturnChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Level 3: Whenever you cast an instant or sorcery spell, create a 1/1 blue and red Otter token.
      class LevelThreeTrigger < TriggeredAbility::SpellCast
        def should_perform?
          actor.level >= 3 && event.player == controller && (spell.instant? || spell.sorcery?)
        end

        def call
          trigger_effect(:create_token, token_class: Tokens::Otter)
        end
      end

      def event_handlers
        super.merge(Events::ClassLevelGained => LevelTwoTrigger, Events::SpellCast => LevelThreeTrigger)
      end
    end
  end
end
