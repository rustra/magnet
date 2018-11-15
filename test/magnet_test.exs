defmodule MagnetTest do
  use ExUnit.Case
  doctest Magnet

  test "decode an empty magnet uri" do
    assert %Magnet{} = Magnet.decode("magnet:?") |> Enum.into(%Magnet{})
  end

  test "decode a valid magnet uri" do
    magnet =
      ~w(magnet:?
          xt=urn:ed2k:354B15E68FB8F36D7CD88FF94116CDC1
         &xt=urn:tree:tiger:7N5OAMRNGMSSEUE3ORHOKWN4WWIQ5X4EBOOTLJY
         &xt=urn:btih:QHQXPYWMACKDWKP47RRVIV7VOURXFE5Q
         &xl=10826029
         &dn=mediawiki-1.15.1.tar.gz
         &tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80%2Fannounce
         &as=http%3A%2F%2Fdownload.wikimedia.org%2Fmediawiki%2F1.15%2Fmediawiki-1.15.1.tar.gz
         &xs=http%3A%2F%2Fcache.example.org%2FXRX2PEFXOOEJFRVUCX6HMZMKS5TWG4K5
         &xs=dchub://example.org
      ) |> Enum.join

    assert %Magnet{name: "mediawiki-1.15.1.tar.gz",
                   announce: ["udp://tracker.openbittorrent.com:80/announce"],
                   fallback: "http://download.wikimedia.org/mediawiki/1.15/mediawiki-1.15.1.tar.gz",
                   info_hash: ["urn:ed2k:354B15E68FB8F36D7CD88FF94116CDC1",
                               "urn:tree:tiger:7N5OAMRNGMSSEUE3ORHOKWN4WWIQ5X4EBOOTLJY",
                               "urn:btih:QHQXPYWMACKDWKP47RRVIV7VOURXFE5Q"],
                   length: 10826029,
                   source: ["http://cache.example.org/XRX2PEFXOOEJFRVUCX6HMZMKS5TWG4K5",
                            "dchub://example.org"]
                  } = Magnet.decode(magnet) |> Enum.into(%Magnet{})
  end

  test "zero length file" do
    magnet =
      ~w(magnet:?
          xt=urn:ed2k:31D6CFE0D16A9E31B735C9D70EC089C0
         &xl=0
         &dn=zero_len.file
         &xt=urn:bitprint:3I42H3S6NNF2QMSVX7XZKYAYSCX5QBYJ.LWPNAQCDBZRYXW3VJHVCJ64QBZNGHOHHHZWCLNQ
         &xt=urn:md5:D42D8CD98F00B2049E800989ECF8427E
      ) |> Enum.join

    assert %Magnet{name: "zero_len.file",
                   length: 0,
                   info_hash: [
                     "urn:ed2k:31D6CFE0D16A9E31B735C9D70EC089C0",
                     "urn:bitprint:3I42H3S6NNF2QMSVX7XZKYAYSCX5QBYJ.LWPNAQCDBZRYXW3VJHVCJ64QBZNGHOHHHZWCLNQ",
                     "urn:md5:D42D8CD98F00B2049E800989ECF8427E"]
                  } = Magnet.decode(magnet) |> Enum.into(%Magnet{})

  end

  test "empty values should not break the decoder" do
    magnet = "magnet:?xt=&as=&kt=&mt=&tr=&xl=&xs="
    assert %Magnet{} = Magnet.decode(magnet) |> Enum.into(%Magnet{})
  end

  test "extracting keywords" do
    magnet = "magnet:?kt=foo+bar+baz"
    assert %Magnet{keywords: ["foo", "bar", "baz"]} = Magnet.decode(magnet) |> Enum.into(%Magnet{})

    magnet = "magnet:?kt=foo&kt=bar&kt=baz"
    assert %Magnet{keywords: ["foo", "bar", "baz"]} = Magnet.decode(magnet) |> Enum.into(%Magnet{})

    magnet = "magnet:?kt=foo"
    assert %Magnet{keywords: ["foo"]} = Magnet.decode(magnet) |> Enum.into(%Magnet{})

    magnet = "magnet:?kt=foo+foo+foo"
    assert %Magnet{keywords: ["foo"]} = Magnet.decode(magnet) |> Enum.into(%Magnet{})

    magnet = "magnet:?kt.1=foo+foo+foo&kt.2=bar"
    assert %Magnet{keywords: ["foo", "bar"]} = Magnet.decode(magnet) |> Enum.into(%Magnet{})

  end

  test "decode entries with dot-number suffixes" do
    magnet_url = ~w(
      magnet:?
       xt.1=urn:sha1:YNCKHTQCBWTRJNIV4WNAE52SJUQCZ5OC
      &xt.2=urn:sha1:TXGCZTQH2N6L6OUQAJJPFLAHG2LTGBC7
      ) |> Enum.join

    assert %Magnet{info_hash: ["urn:sha1:YNCKHTQCBWTRJNIV4WNAE52SJUQCZ5OC",
                               "urn:sha1:TXGCZTQH2N6L6OUQAJJPFLAHG2LTGBC7"]
                  } = Magnet.decode(magnet_url) |> Enum.into(%Magnet{})
  end

  test "announce lists should get dedubbed" do
    magnet = ~w(
      magnet:?
      xt=urn:ed2k:3541B56E8FB8F3D76C8DF8F94161CDC1
      &tr=udp%3A%2F%2Ftracker.example4.com%3A80
      &tr=udp%3A%2F%2Ftracker.example4.com%3A80
      &tr=udp%3A%2F%2Ftracker.example5.com%3A80
      &tr=udp%3A%2F%2Ftracker.example3.com%3A6969
      &tr=udp%3A%2F%2Ftracker.example2.com%3A80
      &tr=udp%3A%2F%2Ftracker.example1.com%3A1337
    ) |> Enum.join

    assert %Magnet{announce: ["udp://tracker.example4.com:80",
                              "udp://tracker.example5.com:80",
                              "udp://tracker.example3.com:6969",
                              "udp://tracker.example2.com:80",
                              "udp://tracker.example1.com:1337"]
                  } = Magnet.decode(magnet) |> Enum.into(%Magnet{})
  end

  test "should support experimental keys" do
    magnet = ~w(
      magnet:?
      x.my_experiment=very_experimental
    ) |> Enum.join

    assert %Magnet{experimental: %{"my_experiment" => "very_experimental"}} = Magnet.decode(magnet) |> Enum.into(%Magnet{})
  end

  test "the name should be decoded" do
    magnet = "magnet:?dn=Name%20%28with%20special%20characters%29"

    assert %Magnet{name: "Name (with special characters)"} =
      Magnet.decode(magnet) |> Enum.into(%Magnet{})
  end
end
