defmodule Absinthe.Phase.Subscription.GetOrdinal do
  use Absinthe.Phase

  alias Absinthe.Phase.Subscription.SubscribeSelf

  @moduledoc false

  alias Absinthe.Blueprint

  @spec run(any, Keyword.t()) :: {:ok, Blueprint.t()}
  def run(blueprint, _options \\ []) do
    with %{type: :subscription, selections: [field]} <- Blueprint.current_operation(blueprint),
         # I commented out the following line because it causes problems for me
         # and since I do not use the ordinal feature I can not properly test it for you so I will refrain from changing anything here
         # The reason why this causes a problem is that I (and I assume many others) have side effects in their subscription config function.
         # And this causes it to be called multiple times. This breaks my entire app and will probably have to be
         # done differently unless you want the library to have breaking changes for many users
         # {:ok, config} = SubscribeSelf.get_config(field, blueprint.execution.context, blueprint)
         {:ok, config} = {:ok, %{}},
         ordinal_fun when is_function(ordinal_fun, 1) <- config[:ordinal] do
      result = ordinal_fun.(blueprint.execution.root_value)
      {:ok, %{blueprint | result: Map.put(blueprint.result, :ordinal, result)}}
    else
      f when is_function(f) ->
        IO.write(
          :stderr,
          "Ordinal function must be 1-arity"
        )

        {:ok, blueprint}

      _ ->
        {:ok, blueprint}
    end
  end
end
