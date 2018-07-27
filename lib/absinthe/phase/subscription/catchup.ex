defmodule Absinthe.Phase.Subscription.Catchup do
  @moduledoc false

  @spec run(any(), Keyword.t()) :: Phase.result_t()
  def run(blueprint, _options \\ []) do
    :ok = blueprint.execution.acc.catchup_fun.()

    {:ok, blueprint}
  end
end
