require 'spec_helper'

describe Rafters::Component do
  before do
    class FooBarComponent < Rafters::Component; end
  end

  after do
    Object.send(:remove_const, 'FooBarComponent') if defined?(FooBarComponent)
  end

  let(:controller) do 
    double("Controller", params: {})
  end

  subject do 
    component = FooBarComponent.new("heading")
    component.controller = controller
    component
  end

  describe "#excute_callbacks!" do
    before do
      FooBarComponent.before_render(:foo)
      FooBarComponent.before_render(:bar)
    end

    it "calls all methods in the provided callback stack" do
      expect(subject).to receive(:foo).ordered
      expect(subject).to receive(:bar).ordered
      subject.execute_callbacks!(:before_render_callbacks)
    end
  end

  describe "#options" do
    it "replaces proc values with their result" do
      FooBarComponent.option :wrapper, lambda { |component| component.is_a?(Rafters::Component) }
      expect(subject.options.wrapper).to be_true
    end

    it "replaces truthy string values with boolean true" do
      FooBarComponent.option :wrapper, "true"
      expect(subject.options.wrapper).to be_true
    end

    it "replaces falsey string values with boolean false" do
      FooBarComponent.option :wrapper, "false"
      expect(subject.options.wrapper).to be_false
    end

    context "with default options" do
      before do
        FooBarComponent.option :view_name, "foo_bar_component"
      end

      it "returns the default values for those options" do
        expect(subject.options.view_name).to eq("foo_bar_component")
      end

      context "and local options" do
        before do
          subject.local_options = { view_name: "foo_component" }
        end

        it "returns the local values for those options" do
          expect(subject.options.view_name).to eq("foo_component")
        end
      end

      context "and param options" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { view_name: "baz_component" } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those options" do
          expect(subject.options.view_name).to eq("baz_component")
        end
      end
    end

    context "with local options" do
      before do
        subject.local_options = { view_name: "lipsum_component" }
      end

      it "returns the locally defined values for those options" do
        expect(subject.options.view_name).to eq("lipsum_component")
      end

      context "and param options" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { view_name: "dolor_component" } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those options" do
          expect(subject.options.view_name).to eq("dolor_component")
        end
      end
    end

    context "with param options" do
      let(:params) do
        HashWithIndifferentAccess.new({ heading: { view_name: "bacon_component" } })
      end

      before do
        controller.stub(:params).and_return(params)
      end

      it "returns the param values for those options" do
        expect(subject.options.view_name).to eq("bacon_component")
      end
    end
  end

  describe "#settings" do
    it "replaces proc values with their result" do
      FooBarComponent.setting :title, default: lambda { |component| component.class.name.titleize }
      expect(subject.settings.title).to eq("Foo Bar Component")
    end

    it "replaces truthy string values with boolean true" do
      FooBarComponent.setting :published, default: "true"
      expect(subject.settings.published).to be_true
    end

    it "replaces falsey string values with boolean false" do
      FooBarComponent.setting :published, default: "false"
      expect(subject.settings.published).to be_false
    end

    context "with required settings" do
      before do
        FooBarComponent.setting :title, required: true
      end

      it "raises an error if the required setting is nil" do
        expect { subject.settings }.to raise_error(Rafters::Component::SettingRequired)
      end

      it "does not raise an error if the required setting is not nil" do
        subject.local_settings[:title] = "Foo Bar"
        expect { subject.settings }.not_to raise_error(Rafters::Component::SettingRequired)
      end
    end

    context "with default settings" do
      before do
        FooBarComponent.setting :title, default: "Heading Component"
      end

      it "returns the default values for those settings" do
        expect(subject.settings.title).to eq("Heading Component")
      end

      context "and local settings" do
        before do
          subject.local_settings = { title: "Foo Heading" }
        end

        it "returns the local values for those settings" do
          expect(subject.settings.title).to eq("Foo Heading")
        end
      end

      context "and param settings" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { settings: { title: "Baz Component" } } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those settings" do
          expect(subject.settings.title).to eq("Baz Component")
        end
      end
    end

    context "with local settings" do
      before do
        subject.local_settings = { title: "Lorem Component" }
      end

      it "returns the locally defined values for those settings" do
        expect(subject.settings.title).to eq("Lorem Component")
      end

      context "and param settings" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { settings: { title: "Dolor Component" } } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those settings" do
          expect(subject.settings.title).to eq("Dolor Component")
        end
      end
    end

    context "with param settings" do
      let(:params) do
        HashWithIndifferentAccess.new({ heading: { settings: { title: "Bacon Component" } } })
      end

      before do
        controller.stub(:params).and_return(params)
      end

      it "returns the param values for those settings" do
        expect(subject.settings.title).to eq("Bacon Component")
      end
    end
  end

  describe "#attributes" do
    before do
      FooBarComponent.send(:define_method, :title, -> { "Heading Component" })
      FooBarComponent.attribute(:title)
    end

    it "returns the values of defined attributes" do
      expect(subject.attributes.title).to eq("Heading Component")
    end
  end

  describe "#source" do
    before do
      class FooSource < Rafters::Source; end
      FooBarComponent.register_source(:foo, 'FooSource')
      subject.local_options = { source_name: "foo" }
    end

    it "returns an instance of the provided source name's class" do
      expect(subject.source).to be_an_instance_of(FooSource)
    end

    it "sets the source's component delegate to itself" do
      expect(subject.source.component).to eq(subject)
    end

    context "with an unregistered source" do
      before do
        subject.local_options = { source_name: "bar" }
      end

      it "raises an error" do
        expect { subject.source }.to raise_error(Rafters::Component::UnknownSource)
      end
    end
  end

  describe "#view" do
    before do
      FooBarComponent.register_view(:foo_bar)
      subject.local_options = { view_name: "foo_bar" }
    end

    it "returns a hash containing the view's name" do
      expect(subject.view[:name]).to eq("foo_bar")
    end

    context "with declared attributes" do
      before do
        FooBarComponent.register_view(:baz, attributes: [:foo, :bar, :baz])
        subject.local_options = { view_name: "baz" }
      end

      it "returns a hash containing the declared attributes" do
        expect(subject.view[:attributes]).to eq([:foo, :bar, :baz])
      end
    end
  end

  describe "#locals" do
    before do
      FooBarComponent.send(:define_method, :title, -> { "Heading Component" })
      FooBarComponent.attribute(:title)
      FooBarComponent.setting(:foo, default: "bar")
    end

    it "includes all defined attributes for the component" do
      expect(subject.locals[:title]).to eq("Heading Component")
    end

    it "includes settings for the component" do
      expect(subject.locals[:settings]).to eq(Hashie::Mash.new(foo: "bar"))
    end

    it "includes the component" do
      expect(subject.locals[:component]).to eq(subject)
    end
  end

  describe "#as_json" do
    before do
      FooBarComponent.option(:source_name, "FooSource")
      FooBarComponent.setting(:foo, default: "bar")
    end

    it "includes the component's identifier" do
      expect(subject.as_json["identifier"]).to eq(subject.identifier)
    end

    it "includes the component's options" do
      expect(subject.as_json["options"]).to eq({ source_name: "FooSource", view_name: "foo_bar_component", wrapper: true }.stringify_keys!)
    end

    it "includes the component's settings" do
      expect(subject.as_json["settings"]).to eq({ foo: "bar" }.stringify_keys!)
    end

    context "when some settings are suppressed" do
      before do
        FooBarComponent.setting(:bar, default: "baz", suppress: true)
      end

      it "does not include the suppressed settings in the output" do
        expect(subject.as_json["settings"]).to eq({ foo: "bar" }.stringify_keys!)
      end
    end
  end

  describe "#controller" do
    context "when the argument is an instance variable in the controller" do
      before do
        controller.instance_variable_set("@foo", "bar")
      end

      it "returns the instance variable's value" do
        expect(subject.controller(:foo)).to eq("bar")
      end
    end

    context "when the argument is an instance method in the controller" do
      before do
        controller.stub(:bar).and_return("baz")
      end

      it "returns the instance method's value" do
        expect(subject.controller(:bar)).to eq("baz")
      end
    end

    context "when the argument is not defined in the controller" do
      it "returns nil" do
        expect(subject.controller(:baz)).to be_nil
      end
    end
  end

  describe "when subclassed" do
    before do
      class FooComponent < Rafters::Component; end
    end

    it "sets the default wrapper option" do
      expect(FooComponent._options[:wrapper]).to be_true
    end

    it "sets the default view_name option" do
      expect(FooComponent._options[:view_name]).to eq("foo_component")
    end

    it "sets the default source_name option" do
      expect(FooComponent._options[:source_name]).to be_nil
    end
  end

  describe ".setting" do
    before do
      FooBarComponent.setting(:published)
    end

    it "adds the provided setting name to the list of available settings" do
      expect(subject.settings).to have_key("published")
    end

    context "when provided a default" do
      before do
        FooBarComponent.setting(:archived, default: false)
      end

      it "adds the default to the list of default settings" do
        expect(subject.settings.archived).to be_false
      end
    end
  end

  describe ".settings" do
    before do
      FooBarComponent.settings(foo: nil, bar: nil, baz: nil)
    end

    it "adds all given settings to the list of available settings" do
      expect(subject.settings).to have_key(:foo)
      expect(subject.settings).to have_key(:bar)
      expect(subject.settings).to have_key(:baz)
    end
  end

  describe ".attribute" do
    before do
      FooBarComponent.send(:define_method, :foo, -> { "foo" })
      FooBarComponent.attribute(:foo)
    end

    it "adds the provided method name to the list of attributes" do
      expect(subject.attributes.foo).to eq("foo")
    end
  end

  describe ".attributes" do
    before do
      FooBarComponent.send(:define_method, :foo, -> { "foo" })
      FooBarComponent.send(:define_method, :bar, -> { "bar" })
      FooBarComponent.send(:define_method, :baz, -> { "baz" })
      FooBarComponent.attributes(:foo, :bar, :baz)
    end

    it "adds the provided method names to the list of attributes" do
      expect(subject.attributes).to have_key(:foo)
      expect(subject.attributes).to have_key(:bar)
      expect(subject.attributes).to have_key(:baz)
    end
  end

  describe ".option" do
    before do
      FooBarComponent.option(:wrapper, false)
    end

    it "sets the value of the option to the provided value" do
      expect(subject.options.wrapper).to be_false
    end
  end

  describe ".options" do
    before do
      FooBarComponent.options(wrapper: false, view_name: "lorem")
    end

    it "sets the values of the given options to the provided value" do
      expect(subject.options.wrapper).to be_false
      expect(subject.options.view_name).to eq("lorem")
    end
  end

  describe ".before_render" do
    before do
      FooBarComponent.before_render(:foo)
    end

    it "adds the given method to the list of methods that execute before rendering" do
      expect(subject.send(:before_render_callbacks)).to match_array([:foo])
    end
  end

  describe ".after_render" do
    before do
      FooBarComponent.after_render(:foo)
    end

    it "adds the given method to the list of methods that execute after rendering" do
      expect(subject.send(:after_render_callbacks)).to match_array([:foo])
    end
  end
end
