defmodule Absinthe.Phase.Subscription.Result do
  @moduledoc false

  # This runs instead of resolution and the normal result phase after a successful
  # subscription

  alias Absinthe.Blueprint
  alias Absinthe.Blueprint.Continuation

  @spec run(any, Keyword.t()) :: {:ok, Blueprint.t()}
  def run(blueprint, options) do
    topic = Keyword.get(options, :topic)
    catchup = Keyword.get(options, :catchup)
    result = %{"subscribed" => topic}
    case catchup do
      nil ->
        {:ok, put_in(blueprint.result, result)}

      catchup_fun when is_function(catchup_fun, 0) ->
        {:ok, catchup_results} = catchup_fun.()

        result =
          if catchup_results != [] do
            continuations =
              Enum.map(catchup_results, fn cr ->
                %Continuation{
                  phase_input: blueprint,
                  pipeline: [
                    {Absinthe.Phase.Subscription.Catchup, [catchup_result: cr]},
                    {Absinthe.Phase.Document.Execution.Resolution, options},
                    Absinthe.Phase.Document.Result
                  ]
                }
              end)

            Map.put(result, :continuation, continuations)
          else
            result
          end

        {:ok, put_in(blueprint.result, result)}

      val ->
        raise """
        Invalid catchup function. Must be a function of arity 0.

        #{inspect(val)}
        """
    end
  end
end
