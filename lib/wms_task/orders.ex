defmodule WmsTask.Orders do
  alias WmsTask.Orders.Order
  alias WmsTask.Orders.Piking
  alias WmsTask.Repo

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Piking{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of pickings.

  ## Examples

      iex> list_pickings()
      [%Piking{}, ...]

  """
  def list_orders do
    Repo.all(Order)
  end


end
