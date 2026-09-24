# frozen_string_literal: true

module Magic
  class CardParser
    # A one-sentence game effect ("~ deals 3 damage to any target."). Effects are
    # reusable by any rule that needs one: instants and sorceries today, triggers
    # and activated abilities later. Each lives in lib/magic/card_parser/effects/.
    #
    #   Effect.parse(text)  -> effect instance, or nil
    #   #target_choices     -> Ruby expression for the legal targets, or nil when untargeted
    #   #resolve_call       -> Ruby statement that does the effect (`target` is in scope when targeted;
    #                          Effect::THIS stands for the card/permanent, e.g. as a Choice's actor)
    #   #earlier_target?    -> true when it acts on an earlier effect's `target` ("Untap it.")
    #   #definitions        -> Ruby defining constants resolve_call needs (a token class), or nil
    #   #choice_base        -> Choice class the effect adds (e.g. scry), or nil; the
    #                          effects after it run in a subclass named #choice_class_name,
    #                          created with #choice_args (see EffectList)
    module Effect
      # Placeholder in resolve_call/target_choices for the card or permanent the
      # effect belongs to ("~ gets +1/+1"); EffectList swaps in Ruby for it.
      THIS = "__this__"

      def self.all
        CardParser.load_all("effects", Effects)
      end

      def self.parse(text)
        all.lazy.filter_map { |effect| effect.parse(text) }.first
      end

      def target_choices = nil
      # True for "it" / "that creature": the effect acts on an earlier effect's target.
      def earlier_target? = false
      def choice_base = nil
      def choice_args = nil
      def definitions = nil
    end
  end
end
