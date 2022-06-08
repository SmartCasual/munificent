require "factory_bot/namespaced_factories"

module Munificent
  module Factories
    def self.define(name, &)
      FactoryBot.define do
        with_namespace(:Munificent, require_prefix: false) do
          factory(name, &)
        end
      end
    end
  end
end
