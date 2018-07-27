defmodule Absinthe.Phase.Subscription.Result do
  @moduledoc false

  # This runs instead of resolution and the normal result phase after a successful
  # subscription

  alias Absinthe.Blueprint
  alias Absinthe.Blueprint.Continuation

  @spec run(any, Keyword.t()) :: {:ok, Blueprint.t()}
  def run(blueprint, [topic: topic, catchup: catchup]) do
    result = %{"subscribed" => topic}
    case catchup do
      nil ->
        {:ok, put_in(blueprint.result, result)}

      fun when is_function(fun, 0) ->
        acc =
          blueprint.execution.acc
          |> Map.put(:catchup_fun, fun)
          |> Map.put(:topic, topic)

        blueprint = put_in(blueprint.execution.acc, acc)

        continuation = %Continuation{
          phase_input: blueprint,
          pipeline: [
            Absinthe.Phase.Subscription.Catchup,
          ]
        }

        result = Map.put(result, :continuation, [continuation])
        {:ok, put_in(blueprint.result, result)}

      val ->
        raise """
        Invalid catchup function. Must be a function of arity 0.

        #{inspect(val)}
        """
    end
  end
end
