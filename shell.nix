with import <nixpkgs> {}; {
  thesisEnv = stdenv.mkDerivation {
    name = "thesisEnv";
    buildInputs = [
        (texlive.combine {
          inherit (texlive) 
          scheme-small
          biber
          collection-langcyrillic
          csquotes
          tabu
          varwidth
          floatrow
          algorithms
          algorithmicx
          enumitem
          biblatex
          biblatex-gost
          logreq
          xstring
          lastpage
          totcount
          chngcntr
          titlesec
          paratype
          was
          filecontents;
        })
      biber
    ];
  };
}

