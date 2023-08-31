defmodule AppWeb.TableComponentTest do
  use AppWeb.ConnCase, async: true
  alias AppWeb.TableComponent
  import Phoenix.LiveViewTest

  @column [
    %{label: "Person Id", key: "person_id"},
    %{label: "Num Items", key: "num_items"}
  ]

  test "renders table correctly" do
    component_rendered =
      render_component(TableComponent,
        column: @column,
        sort_column: :person_id,
        sort_order: :asc,
        rows: []
      )

    assert component_rendered =~ "Person Id"
    assert component_rendered =~ "Num Items"

    assert component_rendered =~ "person_id"
    assert component_rendered =~ "num_items"

    assert component_rendered =~ "arrow_up"
    assert component_rendered =~ "invisible_arrow_up"
  end

  test "renders table correctly with desc arrow" do
    component_rendered =
      render_component(TableComponent,
        column: @column,
        sort_column: :person_id,
        sort_order: :desc,
        rows: []
      )

    assert component_rendered =~ "Person Id"
    assert component_rendered =~ "Num Items"

    assert component_rendered =~ "person_id"
    assert component_rendered =~ "num_items"

    assert component_rendered =~ "arrow_down"
    assert component_rendered =~ "invisible_arrow_up"
  end
end
