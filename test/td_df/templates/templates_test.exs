defmodule TdDf.TemplatesTest do
  use TdDf.DataCase

  import Ecto.Changeset

  alias TdCache.TemplateCache
  alias TdDf.Repo
  alias TdDf.Templates
  alias TdDf.Templates.Template

  @valid_attrs %{
    content: [
      %{
        "name" => "some_group",
        "fields" => [
          %{
            "name" => "some_field",
            "label" => "some label",
            "widget" => "some_widget",
            "type" => "some_type",
            "cardinality" => "?"
          }
        ]
      }
    ],
    label: "some name",
    name: "some_name",
    scope: "bg"
  }
  @update_attrs %{
    content: [
      %{
        "name" => "some_updated_group",
        "fields" => [
          %{
            "name" => "some_field",
            "label" => "some label",
            "widget" => "some_widget",
            "type" => "some_type",
            "cardinality" => "?"
          }
        ]
      }
    ],
    label: "some updated name",
    name: "some_name",
    scope: "dq"
  }
  @invalid_attrs %{content: nil, label: nil, name: nil}

  describe "templates" do
    test "list_templates/0 returns all templates" do
      template = template_fixture()
      assert [_ | _] = templates = Templates.list_templates()
      assert Enum.any?(templates, &(&1 == template))
      assert Enum.any?(templates, &(&1.scope == "ca" and &1.name == "config_metabase"))
    end

    test "list_templates/1 with scope filter returns templates filtered by the given value for the scope" do
      attrs = %{scope: "bg"}
      templates_fixture = list_templates_fixture()
      filtered_templates = Templates.list_templates(attrs)
      assert length(filtered_templates) == 2

      assert Enum.all?(filtered_templates, fn ft ->
               Enum.any?(templates_fixture, &(ft.id == &1.id))
             end)
    end

    test "list_templates/1 with scope filter returns templates filtered by several scope values" do
      scope_values = ["bg", "dq"]
      attrs = %{scope: scope_values}
      list_templates_fixture()
      filtered_templates = Templates.list_templates(attrs)
      assert length(filtered_templates) == 3

      assert Enum.all?(filtered_templates, fn ft -> Enum.any?(scope_values, &(&1 == ft.scope)) end)
    end

    test "get_template!/1 returns the template with given id" do
      template = template_fixture()
      assert Templates.get_template!(template.id) == template
    end

    test "get_template_by_name!/1 returns the template with given name" do
      template = insert(:template)
      assert Templates.get_template_by_name!(template.name) == template
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Templates.create_template(@valid_attrs)

      assert template.content == [
               %{
                 "name" => "some_group",
                 "fields" => [
                   %{
                     "name" => "some_field",
                     "label" => "some label",
                     "widget" => "some_widget",
                     "type" => "some_type",
                     "cardinality" => "?"
                   }
                 ]
               }
             ]

      assert template.label == "some name"
      assert template.name == "some_name"
      assert template.scope == "bg"

      template_cache = TemplateCache.get_by_name!("some_name")
      assert template.content == template_cache.content
      assert template.label == template_cache.label
      assert template.scope == template_cache.scope
      assert to_string(template.updated_at) == template_cache.updated_at
    end

    test "create_template/1 allows to create template name with spaces" do
      template = template_fixture(%{name: "name with space"})
      assert template.name == "name with space"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Templates.create_template(@invalid_attrs)
    end

    test "create_template/1 with no group in content returns error changeset" do
      content = []

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid_content.no_groups", []}

      content = nil

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"can't be blank", [{:validation, :required}]}
    end

    test "create_template/1 with repeated group name in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [%{"name" => "f1", "label" => "labelf1"}]
        },
        %{
          "name" => "group1",
          "fields" => [%{"name" => "f2", "label" => "labelf2"}]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"repeated.group", [name: "group1"]}
    end

    for name_value <- [nil, ""] do
      @tag name_value: name_value
      test "create_template/1 with type #{if is_nil(name_value), do: "nil", else: "empty string"} group name in content",
           %{
             name_value: name_value
           } do
        content = [
          %{
            "name" => name_value,
            "fields" => [
              %{
                "name" => "f1",
                "label" => "labelf1",
                "widget" => "widget1",
                "type" => "type1",
                "cardinality" => "?"
              }
            ]
          }
        ]

        attrs = Map.put(@valid_attrs, :content, content)
        assert {:ok, %Template{}} = Templates.create_template(attrs)
      end
    end

    test "create_template/1 with no field in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => []
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid_group.no_fields", []}

      content = [
        %{
          "name" => "group1",
          "fields" => nil
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid_group.no_fields", []}
    end

    test "create_template/1 with repeated name field in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{"name" => "repeated_field", "label" => "label1"},
            %{"name" => "my name", "label" => "label2"}
          ]
        },
        %{
          "name" => "group2",
          "fields" => [%{"name" => "repeated_field", "label" => "label1"}]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"repeated.field", [name: "repeated_field"]}
    end

    test "create_template/1 with an empty field name in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "",
              "label" => "f1 label",
              "widget" => "widget1",
              "type" => "type1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.name", [{:name, ""}]}

      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => nil,
              "label" => "f1 label",
              "widget" => "widget1",
              "type" => "type1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.name", [{:name, nil}]}
    end

    test "create_template/1 with an empty field label in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => "",
              "widget" => "widget1",
              "type" => "type1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.label", [{:name, "f1"}]}

      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => nil,
              "widget" => "widget1",
              "type" => "type1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.label", [{:name, "f1"}]}
    end

    test "create_template/1 with existing fields and different type in another template returns error changeset" do
      insert(:template,
        content: [
          %{
            "name" => "test-group",
            "fields" => [%{"name" => "field1", "type" => "type1"}]
          }
        ]
      )

      content = [
        %{
          "name" => "test-group",
          "fields" => [
            %{"name" => "field1", "type" => "typex"},
            %{"name" => "field2", "type" => "type1"}
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)

      error =
        errors
        |> Keyword.get(:content)
        |> elem(0)

      assert error == "invalid.type"
    end

    test "create_template/1 with existing fields and same type in another template creates the template" do
      insert(:template,
        content: [
          %{
            "name" => "test-group",
            "fields" => [
              %{
                "name" => "field1",
                "widget" => "widget1",
                "type" => "type1",
                "cardinality" => "?"
              }
            ]
          }
        ]
      )

      content = [
        %{
          "name" => "test-group",
          "fields" => [
            %{
              "name" => "field1",
              "label" => "label1",
              "widget" => "widget1",
              "type" => "type1",
              "cardinality" => "?"
            },
            %{
              "name" => "field2",
              "label" => "label2",
              "widget" => "widget2",
              "type" => "type2",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)

      assert template.content == content
    end

    test "create_template/1 with subscribable fields format validation" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "type" => "foo",
              "values" => %{"fixed" => []},
              "subscribable" => true,
              "widget" => "widget1",
              "cardinality" => "?"
            },
            %{
              "name" => "bar",
              "label" => "Bar",
              "type" => "bar",
              "widget" => "widget2",
              "cardinality" => "?"
            },
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "baz",
              "subscribable" => false,
              "widget" => "widget2",
              "cardinality" => "?"
            },
            %{
              "name" => "xyz",
              "label" => "Xyz",
              "type" => "xyz",
              "values" => %{"fixed_tuple" => []},
              "subscribable" => true,
              "widget" => "widget2",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "type" => "foo",
              "values" => %{"fixed" => []},
              "subscribable" => true
            },
            %{"name" => "bar", "label" => "Bar", "type" => "bar"},
            %{"name" => "baz", "label" => "Baz", "type" => "baz", "subscribable" => true}
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.subscribable", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with an empty field widget in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => "f1 label",
              "widget" => "",
              "type" => "type1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.widget", [{:name, "f1"}]}

      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => "f1 label",
              "widget" => nil,
              "type" => "type1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.widget", [{:name, "f1"}]}
    end

    test "create_template/1 with an empty field type in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => "f1 label",
              "widget" => "widget1",
              "type" => "",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.type", [{:name, "f1"}]}

      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => "f1 label",
              "widget" => "widget1",
              "type" => nil,
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.type", [{:name, "f1"}]}
    end

    test "create_template/1 with an empty field cardinality in content returns error changeset" do
      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => "f1 label",
              "widget" => "widget1",
              "type" => "type1",
              "cardinality" => ""
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.cardinality", [{:name, "f1"}]}

      content = [
        %{
          "name" => "group1",
          "fields" => [
            %{
              "name" => "f1",
              "label" => "f1 label",
              "widget" => "widget1",
              "type" => "type1",
              "cardinality" => nil
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:error, %Ecto.Changeset{errors: errors}} = Templates.create_template(attrs)
      assert errors[:content] == {"invalid.field.cardinality", [{:name, "f1"}]}
    end

    test "create_template/1 with role field validation for field type 'user'" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "baz",
              "type" => "user",
              "values" => %{"role_users" => "bar"},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "user",
              "values" => %{"role_users" => ""},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.role_users", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "user",
              "values" => %{"role_users" => nil},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.role_users", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with role field validation for field type 'user_group'" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "xyz",
              "label" => "Xyz",
              "type" => "user_group",
              "values" => %{"role_groups" => "role"},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "xyz",
              "label" => "Xyz",
              "type" => "user_group",
              "values" => %{"role_groups" => ""},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.role_groups", [name: "xyz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "xyz",
              "label" => "Xyz",
              "type" => "user_group",
              "values" => %{"role_groups" => nil},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.role_groups", [name: "xyz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with hierarchy value validation for field type 'hierarchy'" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "hierarchy",
              "values" => %{"hierarchy" => "bar"},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "hierarchy",
              "values" => %{"hierarchy" => ""},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.hierarchy", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "hierarchy",
              "values" => %{"hierarchy" => nil},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.hierarchy", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with hierarchy value validation for field type 'table'" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "table",
              "values" => %{"table_columns" => "bar"},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "table",
              "values" => %{"table_columns" => ""},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.table_columns", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "type" => "table",
              "values" => %{"table_columns" => nil},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.table_columns", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with validation for dropdown/radio/checkout widget and string type value" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{"domain" => %{"3" => ["bazbaz"], "4" => ["bazbazbaz"]}},
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{
                "switch" => %{
                  "on" => "foo",
                  "values" => %{
                    "bazbaz" => ["bazfoo", "foobaz"],
                    "barbar" => ["barfoo", "foobaz"]
                  }
                }
              },
              "cardinality" => "?"
            },
            %{
              "name" => "bar",
              "label" => "Bar",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{"fixed" => ["barbar"]},
              "cardinality" => "?"
            },
            %{
              "name" => "xyz",
              "label" => "Xyz",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{
                "fixed_tuple" => [
                  %{"text" => "xyz_text", "value" => "xyz_value"},
                  %{"text" => "xyzxyz_text", "value" => "xyzxyz_value"}
                ]
              },
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.type", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.type", [name: "foo"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "bar",
              "label" => "Bar",
              "widget" => "checkout",
              "type" => "string",
              "values" => nil,
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.type", [name: "bar"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with validation for fields depending on a domain" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{"domain" => %{"3" => ["bazbaz"], "4" => ["bazbazbaz"]}},
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"domain" => %{"12" => ["foofoo", "foofoofoo"]}},
              "cardinality" => "?"
            },
            %{
              "name" => "bar",
              "label" => "Bar",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{"domain" => %{"7" => ["barbar"]}},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"domain" => %{}},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.domain.field", [name: "foo"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{"domain" => %{"3" => [], "4" => ["bazbaz"]}},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.domain.list", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{"domain" => %{"3" => nil, "4" => ["bazbaz"]}},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.domain.list", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with validation for fields depending on a field" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{
                "switch" => %{
                  "on" => "foo",
                  "values" => %{
                    "bazbaz" => ["bazfoo", "foobaz"],
                    "barbar" => ["barfoo", "foobaz"]
                  }
                }
              },
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed" => ["foofoo", "foofoofoo"]},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{
                "switch" => %{
                  "on" => "",
                  "values" => %{
                    "bazbaz" => ["bazfoo", "foobaz"],
                    "barbar" => ["barfoo", "foobaz"]
                  }
                }
              },
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed" => ["foofoo", "foofoofoo"]},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.switch", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "radio",
              "type" => "string",
              "values" => %{
                "switch" => %{
                  "on" => nil,
                  "values" => %{
                    "bazbaz" => ["bazfoo", "foobaz"],
                    "barbar" => ["barfoo", "foobaz"]
                  }
                }
              },
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed" => ["foofoo", "foofoofoo"]},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.switch", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{
                "switch" => %{
                  "on" => "foo",
                  "values" => %{}
                }
              },
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed" => ["foofoo", "foofoofoo"]},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.switch", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{
                "switch" => %{
                  "on" => "foo",
                  "values" => nil
                }
              },
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed" => ["foofoo", "foofoofoo"]},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.switch", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with validation for fixed list fields" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{"fixed" => ["bazbaz", "bazbazbaz"]},
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed" => ["foofoo", "foofoofoo"]},
              "cardinality" => "?"
            },
            %{
              "name" => "bar",
              "label" => "Bar",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{"fixed" => ["barbar"]},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{"fixed" => []},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.fixed", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed" => []},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.fixed", [name: "foo"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "bar",
              "label" => "Bar",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{"fixed" => []},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.fixed", [name: "bar"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with validation for key value list fields" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{
                "fixed_tuple" => [
                  %{"text" => "baz_text", "value" => "baz_value"},
                  %{"text" => "bazbaz_text", "value" => "bazbaz_value"}
                ]
              },
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{
                "fixed_tuple" => [
                  %{"text" => "foo_text", "value" => "foo_value"},
                  %{"text" => "foofoo_text", "value" => "foofoo_value"}
                ]
              },
              "cardinality" => "?"
            },
            %{
              "name" => "bar",
              "label" => "bar",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{
                "fixed_tuple" => [
                  %{"text" => "bar_text", "value" => "bar_value"},
                  %{"text" => "barbar_text", "value" => "barbar_value"}
                ]
              },
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "widget" => "dropdown",
              "type" => "string",
              "values" => %{"fixed_tuple" => []},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.fixed_tuple", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "widget" => "radio",
              "type" => "string",
              "values" => %{"fixed_tuple" => []},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.fixed_tuple", [name: "foo"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "bar",
              "label" => "Bar",
              "widget" => "checkout",
              "type" => "string",
              "values" => %{"fixed_tuple" => []},
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.values.fixed_tuple", [name: "bar"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "create_template/1 with validation for conditional visibility and mandatory depending fields" do
      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "baz",
              "depends" => %{"on" => "baz", "to_be" => "bazbaz"},
              "type" => "string",
              "widget" => "widget1",
              "cardinality" => "?"
            },
            %{
              "name" => "foo",
              "label" => "Foo",
              "mandatory" => %{"on" => "foo", "to_be" => "foofoo"},
              "type" => "string",
              "values" => %{},
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)
      assert {:ok, %Template{} = template} = Templates.create_template(attrs)
      assert template.content == content

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "depends" => %{"on" => "baz", "to_be" => []},
              "type" => "string",
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.depends.to_be", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "baz",
              "label" => "Baz",
              "depends" => %{"on" => "baz", "to_be" => nil},
              "type" => "string",
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.depends.to_be", [name: "baz"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "mandatory" => %{"on" => "foo", "to_be" => []},
              "type" => "string",
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.mandatory.to_be", [name: "foo"]}],
                valid?: false
              }} = Templates.create_template(attrs)

      content = [
        %{
          "name" => "foo",
          "fields" => [
            %{
              "name" => "foo",
              "label" => "Foo",
              "mandatory" => %{"on" => "foo", "to_be" => nil},
              "type" => "string",
              "widget" => "widget1",
              "cardinality" => "?"
            }
          ]
        }
      ]

      attrs = Map.put(@valid_attrs, :content, content)

      assert {:error,
              %Ecto.Changeset{
                errors: [content: {"invalid.field.mandatory.to_be", [name: "foo"]}],
                valid?: false
              }} = Templates.create_template(attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = template_fixture()
      assert {:ok, template} = Templates.update_template(template, @update_attrs)
      assert %Template{} = template

      assert template.content == [
               %{
                 "name" => "some_updated_group",
                 "fields" => [
                   %{
                     "name" => "some_field",
                     "label" => "some label",
                     "widget" => "some_widget",
                     "type" => "some_type",
                     "cardinality" => "?"
                   }
                 ]
               }
             ]

      assert template.label == "some updated name"
      assert template.name == "some_name"
    end

    test "refresh_cache updates cache information when a template is updated" do
      template = template_fixture()
      {:ok, updated_at} = DateTime.from_unix(DateTime.to_unix(DateTime.utc_now()) + 60)

      attrs =
        @update_attrs
        |> Map.put(:updated_at, updated_at)
        |> Map.put(:content, [%{"name" => "name"}])

      {:ok, template} =
        template
        |> cast(attrs, [:label, :name, :content, :scope, :updated_at])
        |> Repo.update()

      Templates.refresh_cache({:ok, template})
      template_cache = TemplateCache.get_by_name!("some_name")

      assert template.content == template_cache.content
      assert template.label == template_cache.label
      assert template.scope == template_cache.scope
      assert to_string(template.updated_at) == template_cache.updated_at
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = template_fixture()
      assert {:error, %Ecto.Changeset{}} = Templates.update_template(template, @invalid_attrs)
      assert template == Templates.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = template_fixture()
      assert {:ok, %Template{}} = Templates.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Templates.get_template!(template.id) end
    end
  end

  defp template_fixture(attrs \\ %{}) do
    {:ok, template} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Templates.create_template()

    template
  end

  defp list_templates_fixture do
    [
      %{
        content: [
          %{
            "name" => "some_group",
            "fields" => [
              %{
                "name" => "some_field",
                "label" => "some label",
                "widget" => "some_widget",
                "type" => "some_type",
                "cardinality" => "?"
              }
            ]
          }
        ],
        label: "some name",
        name: "some_name",
        scope: "bg"
      },
      %{
        content: [
          %{
            "name" => "some_group1",
            "fields" => [
              %{
                "name" => "some_field",
                "label" => "some label",
                "widget" => "some_widget",
                "type" => "some_type",
                "cardinality" => "?"
              }
            ]
          }
        ],
        label: "some name 1",
        name: "some_name_1",
        scope: "bg"
      },
      %{
        content: [
          %{
            "name" => "some_group2",
            "fields" => [
              %{
                "name" => "some_field",
                "label" => "some label",
                "widget" => "some_widget",
                "type" => "some_type",
                "cardinality" => "?"
              }
            ]
          }
        ],
        label: "some name 2",
        name: "some_name_2",
        scope: "dq"
      },
      %{
        content: [
          %{
            "name" => "some_group3",
            "fields" => [
              %{
                "name" => "some_field",
                "label" => "some label",
                "widget" => "some_widget",
                "type" => "some_type",
                "cardinality" => "?"
              }
            ]
          }
        ],
        label: "some name 3",
        name: "some_name_3",
        scope: "dd"
      }
    ]
    |> Enum.map(&template_fixture/1)
  end
end
