self: super:
{
  nim-unwrapped = super.nim-unwrapped.overrideAttrs ( old: rec {
    version = "1.4.8";
    src = super.fetchurl {
      url = "https://nim-lang.org/download/nim-${version}.tar.xz";
      sha256 = "06j485dmb8369420sx1nkvyim7bfcyrxnq8jcfw9az8x85vwb65p";
    };
  });
}
