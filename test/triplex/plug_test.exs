defmodule Triplex.PlugTest do
  use ExUnit.Case

  import Plug.Test
  alias Triplex.Plug
  alias Triplex.PlugConfig

  test "put_tenant/3 must set the tenant to the given assign" do
    conn =
      :get
      |> conn("/")
      |> Plug.put_tenant("power", PlugConfig.new())
    assert conn.assigns[:current_tenant] == "power"

    handler = fn("oi") -> "olá" end
    conn =
      :get
      |> conn("/")
      |> Plug.put_tenant("oi", PlugConfig.new(tenant_handler: handler))
    assert conn.assigns[:current_tenant] == "olá"

    conn =
      :get
      |> conn("/")
      |> Plug.put_tenant("power", PlugConfig.new(assign: :tenant))
    assert conn.assigns[:tenant] == "power"
  end

  test "ensure_tenant/3 ensure the tenant is loaded" do
    callback = fn(conn, _) ->
      assert conn.halted == true
      "oi"
    end
    result =
      :get
      |> conn("/")
      |> Plug.ensure_tenant("power", PlugConfig.new(failure_callback: callback))

    assert result == "oi"

    callback = fn(conn, _) ->
      assert conn.halted == false
      "tchau"
    end
    result =
      :get
      |> conn("/")
      |> Plug.put_tenant("power", PlugConfig.new())
      |> Plug.ensure_tenant("power", PlugConfig.new(callback: callback))

    assert result == "tchau"
  end
end
