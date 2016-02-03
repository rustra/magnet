defmodule Magnet.Encoder do
  def encode(%Magnet{} = magnet) do
    data =
      magnet
      |> Map.from_struct
      |> Map.to_list
      |> Enum.reduce(%{}, &do_encode/2)

    "magnet:?#{URI.encode_query(data)}"
  end

  defp do_encode({_, []}, acc), do: acc
  defp do_encode({_, nil}, acc), do: acc

  defp do_encode({:name, value}, acc),
    do: Map.put(acc, :dn, value)

  defp do_encode({:length, value}, acc),
    do: Map.put(acc, :xl, value)

  defp do_encode({:announce, [value]}, acc),
    do: Map.put(acc, :tr, value)
  defp do_encode({:announce, values}, acc),
    do: into_group(acc, :tr, values)

  defp do_encode({:fallback, value}, acc),
    do: Map.put(acc, :as, value)

  defp do_encode({:info_hash, [value]}, acc),
    do: Map.put(acc, :xt, value)
  defp do_encode({:info_hash, values}, acc),
    do: into_group(acc, :xt, values)

  defp do_encode({:keywords, [value]}, acc),
    do: Map.put(acc, :kt, value)
  defp do_encode({:keywords, values}, acc),
    do: into_group(acc, :kt, values)

  defp do_encode({:manifest, value}, acc),
    do: Map.put(acc, :mt, value)

  defp do_encode({:source, [value]}, acc),
    do: Map.put(acc, :xs, value)
  defp do_encode({:source, values}, acc),
    do: into_group(acc, :xs, values)

  defp do_encode({:experimental, value}, acc) do
    unless Enum.empty? value do
      Enum.reduce(value, acc, fn {key, value} ->
        Map.put(acc, "x.#{key}", value)
      end)
    else
      acc
    end
  end

  # group multible values (lists) into keys of key-dot-n; key.1, key.2, etc
  defp into_group(acc, key, values) do
    values
    |> Enum.with_index(1)
    |> Enum.reduce(acc, fn {value, index}, acc ->
         Map.put(acc, "#{key}.#{index}", value)
       end)
  end
end
