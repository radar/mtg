# frozen_string_literal: true

module Magic
  class CardParser
    # A rules-text pattern the parser understands. Each rule lives in
    # lib/magic/card_parser/rules/ and owns both halves of the job:
    #
    #   Rule.parse(line)   -> rule instance, or nil when the line isn't this rule's
    #   #dsl_lines         -> lines for the Creature("...") DSL block
    #   #hook              -> :static_abilities / :activated_abilities when the rule
    #                         needs a nested class in the class reopening
    #   #handled_event     -> event class name, for the :event_handlers hook
    #   #body_source       -> Ruby for the class reopening's body (e.g. `enchant "Creature"`)
    #   #class_base_name   -> name for that nested class ("ManaAbility")
    #   #class_source(name)-> Ruby source of the nested class
    #
    # Include this module in a `Data.define(...)` class and it is picked up
    # automatically — no registration needed.
    module Rule
      HOOKS = %i[static_abilities activated_abilities event_handlers].freeze

      def self.all
        CardParser.load_all("rules", Rules)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Combine every instance a card produced for this rule (e.g. two keyword lines).
        def merge(rules) = rules
      end

      # Kinds of card (:instant, :creature, ...) this rule may appear on; nil means any.
      def kinds = nil
      def dsl_lines = []
      def hook = nil
      def body_source = nil
      def class_base_name = nil
      def handled_event = nil
      def class_source(_name) = nil
    end
  end
end
