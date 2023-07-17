{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # uBlock origin
      {id = "bkkmolkhemgaeaeggcmfbghljjjoofoh";} # catppuccin
      {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # SponsorBlock
      {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # dark reader
      {id = "aaekanoannlhnajolbijaoflfhikcgng";} # dark theme for messenger
      {id = "ajhmfdgkijocedmfjonnpjfojldioehi";} # Privacy Pass
      {id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";} # Grammarly
      {id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";} # 1Password
      {id = "mjidkpedjlfnanainpdfnedkdlacidla";} # Mouse gestures
      {id = "ponfpcnoihfmfllpaingbgckeeldkhle";} # Enhancer for YouTube
    ];
  };
}
