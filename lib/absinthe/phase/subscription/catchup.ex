defmodule Absinthe.Phase.Subscription.Catchup do
  @moduledoc false

  @spec run(any(), Keyword.t()) :: Phase.result_t()
  def run(blueprint, [catchup_result: cr]) do
    {:ok, put_in(blueprint.execution.root_value, cr)}
  end
end
