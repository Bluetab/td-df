defmodule TdDfWeb.TemplateRelationView do
  use TdDfWeb, :view
  alias TdDfWeb.TemplateRelationView
  alias TdDfWeb.TemplateView

  def render("index.json", %{template_relations: template_relations}) do
    %{data: render_many(template_relations, TemplateRelationView, "template_relation.json")}
  end

  def render("templates.json", %{templates: templates}) do
    %{data: render_many(templates, TemplateView, "template.json")}
  end

  def render("show.json", %{template_relation: template_relation}) do
    %{data: render_one(template_relation, TemplateRelationView, "template_relation.json")}
  end

  def render("template_relation.json", %{template_relation: template_relation}) do
    %{id: template_relation.id,
      id_template: template_relation.id_template,
      resource_type: template_relation.resource_type,
      resource_id: template_relation.resource_id}
  end
end
