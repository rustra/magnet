defmodule Magnet do
  defstruct(
    name: nil,
    length: nil,
    info_hash: [],
    fallback: nil,
    source: [],
    keywords: [],
    manifest: nil,
    announce: []
  )

  defdelegate decode(data), to: Magnet.Decoder
end

defimpl Collectable, for: Magnet do
  def into(original) do
    {original, fn
      # ignore entries with empty values
      acc, {:cont, {_, ""}} ->
        acc

      # as (Acceptable Source) - Web link to the file online
      acc, {:cont, {"as", value}} ->
        uri = URI.decode value
        %Magnet{acc|fallback: uri}

      # dn (Display Name) - Suggested filename
      acc, {:cont, {"dn", value}} ->
        %Magnet{acc|name: value}

      # kt (Keyword Topic) - Key words for the given torrent
      acc, {:cont, {<<"kt", priority::binary>>, value}} ->
        entry = parse_suffix_number(priority, String.split(value, "+"))
        %Magnet{acc|keywords: [entry|acc.keywords]}

      # mt (Manifest Topic) - link to a file that contains a list of magneto (MAGMA - MAGnet MAnifest)
      acc, {:cont, {"mt", value}} ->
        %Magnet{acc|manifest: value}

      # tr (address TRacker) - Tracker/Announce URLs for BitTorrent downloads
      acc, {:cont, {<<"tr", priority::binary>>, value}} ->
        announce = URI.decode(value)
        entry = parse_suffix_number(priority, announce)
        %Magnet{acc|announce: [entry|acc.announce]}

      # xl (eXact Length) - File size in bytes
      acc, {:cont, {"xl", value}} ->
        length = String.to_integer(value)
        %Magnet{acc|length: length}

      # xs (eXact Source) - peer-to-peer links
      acc, {:cont, {<<"xs", priority::binary>>, value}} ->
        uri = URI.decode(value)
        entry = parse_suffix_number(priority, uri)
        %Magnet{acc|source: [entry|acc.source]}

      # xt (eXact Topic) - URN containing file hash
      acc, {:cont, {<<"xt", priority::binary>>, value}} ->
        entry = parse_suffix_number(priority, value)
        %Magnet{acc|info_hash: [entry|acc.info_hash]}

      acc, :done ->
        keywords =
          acc.keywords
          |> sort_by_priority
          |> List.flatten
          |> Enum.dedup

        %Magnet{acc|info_hash: prepare_list(acc.info_hash),
                    announce: prepare_list(acc.announce),
                    source: prepare_list(acc.source),
                    keywords: keywords}

      _, :halt ->
        :ok
    end}
  end

  defp prepare_list(list) do
    list
    |> sort_by_priority
    |> Enum.dedup
  end

  defp sort_by_priority(priority_list) do
    priority_list
    |> Enum.sort_by(&(elem(&1, 0)))
    |> Enum.map(&(elem(&1, 1)))
  end

  defp parse_suffix_number("", value),
    do: {0, value}
  defp parse_suffix_number(<<".", number::binary>>, value) do
    {num, _} = Integer.parse(number)
    {num, value}
  end
end
