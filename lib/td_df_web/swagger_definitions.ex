defmodule TdDfWeb.SwaggerDefinitions do
  @moduledoc """
   Swagger definitions used by controllers
  """
  import PhoenixSwagger

  def template_swagger_definitions do
    %{
      Template:
        swagger_schema do
          title("Template")
          description("A Template")

          properties do
            label(:string, "Label", required: true)
            name(:string, "Name", required: true)
            content(:array, "Content", required: true)
            scope(:string, "Scope", required: false)
          end

          example(%{
            label: "Template 1",
            name: "Template1",
            content: [
              %{name: "name1", max_size: 100, type: "type1", required: true},
              %{related_area: "related_area1", max_size: 100, type: "type2", required: false}
            ],
            scope: "bg"
          })
        end,
      TemplateCreateUpdate:
        swagger_schema do
          properties do
            template(
              Schema.new do
                properties do
                  label(:string, "Label", required: true)
                  name(:string, "Name", required: true)
                  content(:array, "Content", required: true)
                  scope(:string, "Scope", required: false)
                end
              end
            )
          end
        end,
      Templates:
        swagger_schema do
          title("Templates")
          description("A collection of Templates")
          type(:array)
          items(Schema.ref(:Template))
        end,
      TemplateResponse:
        swagger_schema do
          properties do
            data(Schema.ref(:Template))
          end
        end,
      TemplatesResponse:
        swagger_schema do
          properties do
            data(Schema.ref(:Templates))
          end
        end,
      TemplateItem:
        swagger_schema do
          properties do
            name(:string, "Name", required: true)
          end
        end,
      TemplateItems:
        swagger_schema do
          type(:array)
          items(Schema.ref(:TemplateItem))
        end,
      AddTemplatesToDomain:
        swagger_schema do
          properties do
            templates(Schema.ref(:TemplateItems))
          end
        end,
      Content:
        swagger_schema do
          properties do
            content(Schema.ref(:ContentField), "Content", required: true)
          end
        end,
      ContentField:
        swagger_schema do
          properties do
            field_name(:string, "value", required: true)
          end
        end,
      Errors:
        swagger_schema do
          properties do
            errors(Schema.ref(:FieldError))
          end
        end,
      FieldError:
        swagger_schema do
          properties do
            field_name(:array)
          end
        end
    }
  end
end
