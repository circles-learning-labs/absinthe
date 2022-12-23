defmodule Absinthe.Phase.Subscription.Prime do
  @moduledoc false

  alias Absinthe.Blueprint.Continuation
  alias Absinthe.Phase

  @spec run(any(), Keyword.t()) :: Absinthe.Phase.result_t()
  def run(blueprint, prime_result: prime_result) do
    {:ok, put_in(blueprint.execution.root_value, prime_result)}
  end

  def run(blueprint, prime_fun: prime_fun, resolution_options: _options) do
    prime_fun.(blueprint.execution)
    |> case do
      {:ok, prime_result} ->
        blueprint = put_in(blueprint.execution.root_value, prime_result)
        {:ok, blueprint}

      _ ->
        blueprint = put_in(blueprint.result, :no_more_results)
        {:replace, blueprint, []}
    end
  end

  defp maybe_add_continuations(blueprint, [], _options), do: blueprint

  defp maybe_add_continuations(blueprint, remaining_results, options) do
    continuations =
      Enum.map(
        remaining_results,
        &%Continuation{
          phase_input: blueprint,
          pipeline: [
            {__MODULE__, [prime_result: &1]},
            {Phase.Document.Execution.Resolution, options},
            Phase.Subscription.GetOrdinal,
            Phase.Document.Result
          ]
        }
      )

    put_in(blueprint.result, %{continuations: continuations})
  end
end
