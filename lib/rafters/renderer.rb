class Rafters::Renderer
  def initialize(controller, view_context)
    @controller = controller
    @view_context = view_context

    Rafters.view_paths.each do |view_path|
      @controller.prepend_view_path(view_path)
    end
  end

  def render(component)
    component.controller = @controller
    component.options.wrapper ? render_with_wrapper(component) : render_without_wrapper(component)
  end

  private

  def render_with_wrapper(component)
    @view_context.content_tag(:div, render_without_wrapper(component), class: "component #{component.view_name.dasherize}", id: component.identifier)
  end

  def render_without_wrapper(component)
    @view_context.render(file: "/#{component.view_name}", locals: component.locals)
  end
end
