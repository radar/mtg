module Magic
  module Cards
    class AjaniNacatlAvenger < Planeswalker
      card_name "Ajani, Nacatl Avenger"
      type T::Super::Legendary, T::Planeswalker, "Ajani"
      color_indicator :red, :white
      loyalty 3

      CatWarriorToken = Token.create("Cat Warrior") do
        creature_type "Cat Warrior"
        power 2
        toughness 1
        colors :white
      end

      # "+2: Put a +1/+1 counter on each Cat you control."
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 2
        def description = "Put a +1/+1 counter on each Cat you control."

        def resolve!
          battlefield.controlled_by(controller).creatures.select { _1.type?("Cat") }.each do |cat|
            add_counter Counters::Plus1Plus1, to: cat
          end
        end
      end

      # "...he deals damage equal to the number of creatures you control to any target."
      class DamageChoice < Magic::Choice::Targeted
        def choices = game.any_target

        def choice_amount = 1

        def resolve!(target:)
          deal_damage(battlefield.controlled_by(controller).creatures.count, to: target)
        end
      end

      # "0: Create a 2/1 white Cat Warrior creature token. When you do, if you control a red permanent other than
      # Ajani, he deals damage equal to the number of creatures you control to any target."
      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = 0
        def description = "Create a 2/1 white Cat Warrior creature token. When you do, if you control a red permanent other than Ajani, he deals damage equal to the number of creatures you control to any target."

        def resolve!
          create_token(token: CatWarriorToken)
          return unless battlefield.controlled_by(controller).any? { _1 != source && _1.colors.include?(:red) }

          game.add_choice(DamageChoice.new(actor: source))
        end
      end

      # The opponent picks one permanent of each listed type to keep; they sacrifice the rest.
      class KeepChoice < Magic::Choice::Targeted
        TYPES = [["artifact", :artifact?], ["creature", :creature?], ["enchantment", :enchantment?], ["planeswalker", :planeswalker?]].freeze

        def initialize(actor:, player:, remaining: TYPES, kept: [])
          @player = player
          @remaining = remaining
          @kept = kept
          super(actor: actor)
        end

        def chooser = @player

        def targets? = false

        def prompt = "Choose #{@remaining.first.first} to keep"

        def choices = battlefield.controlled_by(@player).reject(&:land?).select(&@remaining.first.last)

        def choice_amount = 1

        def resolve!(target:) = advance(@kept + [target])

        def decline! = advance(@kept)

        private

        def advance(kept)
          rest = @remaining.drop(1)
          while rest.any?
            nxt = self.class.new(actor: actor, player: @player, remaining: rest, kept: kept)
            return game.add_choice(nxt) if nxt.choices.any?

            rest = rest.drop(1)
          end
          (battlefield.controlled_by(@player).reject(&:land?) - kept).each(&:sacrifice!)
        end
      end

      # "-4: Each opponent chooses an artifact, a creature, an enchantment, and a planeswalker from among the
      # nonland permanents they control, then sacrifices the rest."
      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -4
        def description = "Each opponent chooses an artifact, a creature, an enchantment, and a planeswalker from among the nonland permanents they control, then sacrifices the rest."

        def resolve!
          game.opponents(controller).each do |opponent|
            choice = KeepChoice.new(actor: source, player: opponent)
            choice.choices.any? ? game.add_choice(choice) : choice.send(:advance, [])
          end
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end

    class AjaniNacatlPariah < Creature
      card_name "Ajani, Nacatl Pariah"
      cost generic: 1, white: 1
      legendary_creature_type "Cat Warrior"
      power 1
      toughness 2
      back_face AjaniNacatlAvenger

      # "When Ajani enters, create a 2/1 white Cat Warrior creature token."
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call = create_token(token: AjaniNacatlAvenger::CatWarriorToken)
      end

      class TransformChoice < Magic::Choice::May
        def prompt = "Exile Ajani, then return him transformed?"

        # Ajani may have left the battlefield (or already transformed) before this resolves.
        def resolve!
          actor.exile_and_return_transformed! if actor.zone&.battlefield?
        end
      end

      # "Whenever one or more other Cats you control die, you may exile Ajani, then return him to the battlefield
      # transformed under his owner's control." Cats dying together trigger it once.
      class CatDiesTrigger < TriggeredAbility::Death
        def should_perform?
          event.permanent != actor && event.controller == controller && event.permanent.type?("Cat") && !already_queued?
        end

        def call
          game.add_choice(TransformChoice.new(actor:)) if actor.zone&.battlefield?
        end

        private

        def already_queued?
          [*game.pending_triggers, *game.stack.abilities].any? { _1.is_a?(self.class) && _1.actor == actor }
        end
      end

      def etb_triggers = [ETB]

      def event_handlers = { Events::CreatureDied => CatDiesTrigger }
    end
  end
end
