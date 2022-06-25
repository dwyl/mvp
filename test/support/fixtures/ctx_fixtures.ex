defmodule App.CtxFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Ctx` context.
  """

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> App.Ctx.create_tag()

    tag
  end

  @doc """
  Generate a status.
  """
  def status_fixture(attrs \\ %{}) do
    {:ok, status} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> App.Ctx.create_status()

    status
  end

  @doc """
  Generate a person.
  """
  def person_fixture(attrs \\ %{}) do
    {:ok, person} =
      attrs
      |> Enum.into(%{
        auth_provider: "some auth_provider",
        givenName: "some givenName",
        key_id: 42,
        locale: "some locale",
        picture: "some picture"
      })
      |> App.Ctx.create_person()

    person
  end

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> App.Ctx.create_item()

    item
  end

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}) do
    {:ok, list} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> App.Ctx.create_list()

    list
  end

  @doc """
  Generate a timer.
  """
  def timer_fixture(attrs \\ %{}) do
    {:ok, timer} =
      attrs
      |> Enum.into(%{
        end: ~N[2022-06-24 21:52:00],
        start: ~N[2022-06-24 21:52:00]
      })
      |> App.Ctx.create_timer()

    timer
  end
end
