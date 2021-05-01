defmodule Magnet.Encoder do
  @moduledoc """
  Encodes a `Magnet` struct to a Magnet URI.
  """

  @spec encode(Magnet.t()) :: String.t()
  def encode(%Magnet{} = magnet) do
    data =
      magnet
      |> Map.from_struct()
      |> Map.to_list()
      |> Enum.reduce(%{}, &do_encode/2)
      |> Enum.map_join("&", &encode_kv_pair/1)

    "magnet:?#{data}"
  end

  @spec encode_kv_pair({atom | String.t(), any}) :: String.t()
  defp encode_kv_pair({k, v}) do
    cond do
      k in [:as, :xs, :tr] -> "#{k}=#{URI.encode(v)}"
      is_binary(k) && String.starts_with?(k, "x.") -> "#{k}=#{URI.encode(v)}"
      true -> "#{k}=#{v}"
    end
  end

  @spec do_encode({atom, any}, map) :: map
  defp do_encode({_, []}, acc), do: acc
  defp do_encode({_, nil}, acc), do: acc

  defp do_encode({:name, name}, acc) when is_binary(name),
    do: Map.put(acc, :dn, name)

  defp do_encode({:length, length}, acc) when is_number(length),
    do: Map.put(acc, :xl, length)

  defp do_encode({:announce, [announce]}, acc) when is_binary(announce),
    do: Map.put(acc, :tr, announce)

  defp do_encode({:announce, announces}, acc) when is_list(announces),
    do: into_group(acc, :tr, announces)

  defp do_encode({:fallback, fallback}, acc) when is_binary(fallback),
    do: Map.put(acc, :as, fallback)

  defp do_encode({:info_hash, [info_hash]}, acc) when is_binary(info_hash),
    do: Map.put(acc, :xt, info_hash)

  defp do_encode({:info_hash, info_hashes}, acc) when is_list(info_hashes),
    do: into_group(acc, :xt, info_hashes)

  defp do_encode({:keywords, [keyword]}, acc) when is_binary(keyword),
    do: Map.put(acc, :kt, keyword)

  defp do_encode({:keywords, keywords}, acc) when is_list(keywords),
    do: into_group(acc, :kt, keywords)

  defp do_encode({:manifest, manifest}, acc) when is_binary(manifest),
    do: Map.put(acc, :mt, manifest)

  defp do_encode({:source, [source]}, acc) when is_binary(source),
    do: Map.put(acc, :xs, source)

  defp do_encode({:source, sources}, acc) when is_list(sources),
    do: into_group(acc, :xs, sources)

  defp do_encode({:experimental, experimentals}, acc) when is_map(experimentals) do
    case Enum.empty?(experimentals) do
      false ->
        Enum.reduce(experimentals, acc, fn {key, value}, exp_acc ->
          Map.put(exp_acc, "x.#{key}", value)
        end)

      true ->
        acc
    end
  end

  # Group multible values (lists) into keys of key-dot-n; key.1, key.2, etc
  @spec into_group(map, atom, [String.t()]) :: map
  defp into_group(acc, key, values) do
    values
    |> Enum.with_index(1)
    |> Enum.reduce(acc, fn {value, index}, acc ->
      Map.put(acc, "#{key}.#{index}", value)
    end)
  end
end
