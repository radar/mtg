module Magic
  module Cards
    class MirrormindCrown < Equipment
      card_name "Mirrormind Crown"
      cost generic: 4
      equip [Costs::Mana.new(generic: 2)]

      # Creates `amount` token copies of the equipped creature in place of the tokens that were going
      # to be created.
      class CreateCopies < Effect
        attr_reader :creature, :amount, :token_controller

        def initialize(source:, creature:, amount:, token_controller:)
          super(source:)
          @creature = creature
          @amount = amount
          @token_controller = token_controller
        end

        def resolve!
          amount.times.map do
            Permanent.resolve(game:, owner: token_controller, card: creature.copiable_card, token: true, copy: true, cast: false)
          end
        end
      end

      # "As long as this Equipment is attached to a creature, the first time you would create one or
      # more tokens each turn, you may instead create that many tokens that are copies of equipped
      # creature." (Applied automatically: replacement effects have no "may" yet.)
      class CopyReplacement < ReplacementEffect
        KEY = :mirrormind_crown

        def applies?(effect)
          !receiver.attached_to.nil? && effect.controller == receiver.controller && !receiver.triggered_once_this_turn?(KEY)
        end

        def call(effect)
          receiver.trigger_once_this_turn!(KEY)
          CreateCopies.new(source: receiver, creature: receiver.attached_to, amount: effect.amount, token_controller: effect.controller)
        end
      end

      def replacement_effects = { Effects::CreateToken => CopyReplacement }
    end
  end
end
