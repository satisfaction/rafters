require 'spec_helper'

class FooController < ActionController::Base
  include Rafters::Context
end

class FooComponent < Rafters::Component; end

describe Rafters::Context do
  let(:controller) { FooController.new }
  let(:renderer) { double("Renderer", render: "<p>Output</p>") }
  let(:component) { controller.send(:component, :foo, as: "foo") }

  before do
    Rafters::Renderer.stub(:new).and_return(renderer)
  end

  describe "#render_component" do
    it "renders the provided component" do
      expect(renderer).to receive(:render).with(instance_of(FooComponent))
      controller.render_component(:foo, as: "foo")
    end

    context "with options" do
      it "renders the provided component with the given options" do
        expect(FooComponent).to receive(:new).with("foo", { settings: { test: true } }).and_return(component)
        controller.render_component(:foo, { as: "foo", settings: { test: true } })
      end
    end

    context "with a component that has a rescue_from declared" do
      before do
        class FooBarException < Exception; end
        class BarBazException < Exception; end

        FooComponent.rescue_from(FooBarException) do |component, exception|
          raise BarBazException
        end

        renderer.stub(:render).and_return do
          raise FooBarException
        end
      end

      it "rescues from the provided exception with the provided block" do
        expect { controller.render_component(:foo, { as: "foo" }) }.to raise_error(BarBazException)
      end
    end
  end
end
