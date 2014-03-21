require 'rspec/rails'

module Rafters::ComponentExampleGroup
  extend ActiveSupport::Concern
  include RSpec::Rails::RailsExampleGroup

  included do
    metadata[:type] = :component

    subject do
      described_class.new(described_class.name, {}).tap do |component|
        component.controller = controller
      end
    end
  end

  def controller
    @controller ||= example.metadata[:controller].new.tap do |controller|
      controller.request = ActionController::TestRequest.new
      controller.response = ActionController::TestResponse.new
      controller.params = example.metadata[:params] || HashWithIndifferentAccess.new
    end
  end

  module ClassMethods
    def controller(base_class = nil, &body)
      base_class ||= ApplicationController

      metadata[:controller] ||= Class.new(base_class) do
        def self.name; "AnonymousController"; end
      end

      metadata[:controller].class_eval(&body)
    end

    def params(params = {})
      metadata[:params] ||= params
    end
  end
end
