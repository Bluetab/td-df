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
            is_default(:boolean, "Is Default", required: true)
          end

          example(%{
            label: "Template 1",
            name: "Template1",
            content: [
              %{name: "name1", max_size: 100, type: "type1", required: true},
              %{related_area: "related_area1", max_size: 100, type: "type2", required: false}
            ],
            is_default: false
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
                  is_default(:boolean, "Is Default", required: true)
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
      TemplateRelation:
        swagger_schema do
          title("TemplateRelation")
          description("A Template Relation")

          properties do
            id_template(:integer, "Template ID", required: true)
            resource_id(:integer, "Related Object ID", required: true)
            resource_type(:string, "Related Object Type", required: true)
          end

          example(%{
            id_template: 1,
            resource_id: 5,
            resource_type: "domain"
          })
        end,
      TemplateRelationCreateUpdate:
        swagger_schema do
          properties do
            template_relation(
              Schema.new do
                properties do
                  id_template(:integer, "Template ID", required: true)
                  resource_id(:integer, "Related Object ID", required: true)
                  resource_type(:string, "Related Object Type", required: true)
                end
              end
            )
          end
        end,
      TemplateRelations:
        swagger_schema do
          title("TemplateRelations")
          description("A collection of Template Relations")
          type(:array)
          items(Schema.ref(:TemplateRelation))
        end,
      TemplateRelationResponse:
        swagger_schema do
          properties do
            data(Schema.ref(:TemplateRelation))
          end
        end,
      TemplateRelationsResponse:
        swagger_schema do
          properties do
            data(Schema.ref(:TemplateRelations))
          end
        end,
      TemplateRelationItem:
        swagger_schema do
          properties do
            id_template(:integer, "Template ID", required: true)
            resource_id(:integer, "Related Object ID", required: true)
            resource_type(:string, "Related Object Type", required: true)
          end
        end,
      TemplateRelationItems:
        swagger_schema do
          type(:array)
          items(Schema.ref(:TemplateRelationItem))
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
