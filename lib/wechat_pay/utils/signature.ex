defmodule WechatPay.Utils.Signature do
  @moduledoc """
  Module to sign data
  """

  alias WechatPay.Config

  @doc """
  Sign data

  Returns signed data.
  """
  @spec sign(map) :: String.t
  def sign(data) when is_map(data) do
    sign =
      data
      |> Map.delete(:__struct__)
      |> Enum.sort
      |> Enum.map(&process_param/1)
      |> Enum.reject(&(is_nil(&1)))
      |> List.insert_at(-1, "key=#{Config.apikey}")
      |> Enum.join("&")

    :md5
    |> :crypto.hash(sign)
    |> Base.encode16
  end

  defp process_param({_k, ""}) do
    nil
  end
  defp process_param({_k, nil}) do
    nil
  end
  defp process_param({k, v}) when is_map(v) do
    "#{k}=#{Poison.encode!(v)}"
  end
  defp process_param({k, v}) do
    "#{k}=#{v}"
  end
end
