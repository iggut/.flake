{
  pkgs,
  lib,
  config,
  ...
}: {
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    options = [
      "--cmd cdd"
    ];
  };

  programs.nushell = {
    enable = true;
    #configFile.source = ./config.nu;
    #envFile.source = ./env.nu;
    package = pkgs.nushell;
    configFile = {
      text =
        # nu
        ''
              let-env config = {
              table: {
                mode: rounded
              }
              show_banner: false,
              ls: {
                use_ls_colors: true
                clickable_links: true
              }
              cd: {
                abbreviations: true
               }
              rm: {
                always_trash: true
              }
              history: {
                sync_on_enter: true
              }
              hooks: {
                  # pre_prompt: { print "pre prompt hook" }
                  # pre_execution: { print "pre exec hook" }
                  # env_change: {
                      # PWD: {|before, after| print $"changing directory from ($before) to ($after)" }
                  # }
                  command_not_found: {
                      |cmd| (
                         let foundCommands = (nix-locate --minimal --no-group --type x --type s --top-level --whole-name --at-root ("/bin/" + $cmd) | lines | str replace ".out" "");
                         if ($foundCommands | length) == 0  {
                           print "Command not found"
                        } else if $cmd != "wl-copy" {
                            print "Command is avalible in the following packages"
                            print $foundCommands
                            print ("nix-shell -p " + $foundCommands.0 + " coppied to clipboard")
                            echo ("nix-shell -p " + ($foundCommands | get 0) )| wl-copy;
                        }
                      )
                  }
              }
            }

            export def zl [] {
              # zellij a $(pwd | sd '/' '\\n' | tail -n 1) || zellij --layout ./layout.kdl -s $(pwd | sd '/' '\\n' | tail -n 1)";
              if (zellij a ( pwd | split row '/' | last ) | complete | get exit_code) != 0 {
                zellij --layout ./layout.kdl -s ( pwd | split row '/' | last )
              }
            }

            export def zel [] {
              loop {
                let sessions =  (zellij list-sessions | lines)
                let sel = ($sessions | prepend new |prepend exit |  to text | sk)
                if $sel == "" or $sel == "exit" {
                  break
                } else if $sel in $sessions {
                  zellij attach $sel
                } else if $sel == "new" {
                  let input = (input)
                  zellij -s $input
                }
              }
            }

            export def rebuild [] {
              sudo nixos-rebuild switch --flake ~/nix-files/;
            }

            export def x [name:string] {
              let exten = [ [ex com];
                                ['.tar.bz2' 'tar xjf']
                                ['.tar.gz' 'tar xzf']
                                ['.bz2' 'bunzip2']
                                ['.rar' 'unrar x']
                                ['.tbz2' 'tar xjf']
                                ['.tgz' 'tar xzf']
                                ['.zip' 'unzip']
                                ['.7z' '/usr/bin/7z x']
                                ['.deb' 'ar x']
                                ['.tar.xz' 'tar xvf']
                                ['.tar.zst' 'tar xvf']
                                ['.tar' 'tar xvf']
                                ['.gz' 'gunzip']
                                ['.Z' 'uncompress']
                                ]
              let command = ($exten|where $name =~ $it.ex|first)
              if ($command|is-empty) {
                echo 'Error! Unsupported file extension'
              } else {
                nu -c ($command.com + ' ' + $name)
              }
            }

          export use ".config/nu_script/modules/background_task/job.nu"
          export use ".config/nu_script/modules/network/ssh.nu"
          use ".config/nu_script/custom-completions/zellij/zellij-completions.nu" *
          use ".config/nu_script/custom-completions/git/git-completions.nu" *
          use ".config/nu_script/custom-completions/cargo/cargo-completions.nu" *
          use ".config/nu_script/custom-completions/make/make-completions.nu" *
          use ".config/nu_script/custom-completions/nix/nix-completions.nu" *

                    export def "cargo search" [ query: string, --limit=10] {
                        ^cargo search $query --limit $limit
                        | lines
                        | each {
                            |line| if ($line | str contains "#") {
                                $line | parse --regex '(?P<name>.+) = "(?P<version>.+)" +# (?P<description>.+)'
                            } else {
                                $line | parse --regex '(?P<name>.+) = "(?P<version>.+)"'
                            }
                        }
                        | flatten
                        | each { |r| {name: $r.name, version: $r.version ,description: $r.description, link: ("https://lib.rs/" + $r.name ) } }

                    }

        '';
    };

    envFile = {
      text =
        # nu
        ''
          let-env FOO = 'BAR'
          let-env DIRENV_LOG_FORMAT = ""
          let-env EDITOR = "hx"
          let-env VISUAL = "hx"
          let-env BROWSER = "brave"
        '';
    };

    shellAliases = {
      lg = "lazygit";
      ld = "lazydocker";
      l = "exa -ughH --icons";
      la = "exa -alughH --git --icons";
      ll = "exa -alughH --git --icons";
      calc = "eva";
      c = "clear";
      cat = "bat";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      dl = "yt-dlp -P ~/Videos/downloaded";
      dlcd = "yt-dlp";
      clean = "sudo nix-collect-garbage -d";
      cleanold = "sudo nix-collect-garbage --delete-old";
      gamesteam = "gamescope -e -w 1920 -h 1080 -f -Y -- steam -tenfoot";
      looking-game = "gamescope -w 1920 -h 1080 -f -Y -- looking-glass-client -m KEY_INSERT -F";
      mva = "rsync -rP --remove-source-files";
      rebuilds = "sudo nixos-rebuild switch --flake";
      rebuildb = "sudo nixos-rebuild boot --flake";
      rebuildu = "sudo nixos-rebuild switch --upgrade --flake";
      ns = "nix-shell --command nu -p";
      i = "nix-env -iA nixos.";
    };
  };

  #starship
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      format = lib.concatStrings [
        "[░▒▓](#f5c2e7)"
        "$username"
        "$hostname"
        "[](bg:#f38ba8 fg:#f5c2e7)"
        "$directory"
        "[](fg:#f38ba8 bg:#eb7c92)"
        "$git_branch"
        "$git_status"
        "[](fg:#eb7c92 bg:#e6657f)"
        "$c"
        "$golang"
        "$nodejs"
        "$rust"
        "$docker_context"
        "[](fg:#e6657f bg:#e05a75)"
        "$time"
        "[](fg:#e05a75)"
      ];
      username = {
        show_always = true;
        style_user = "bg:#f5c2e7 fg:#11111b";
        style_root = "bg:#f5c2e7 fg:#11111b";
        format = "[ $user]($style)";
      };
      hostname = {
        ssh_symbol = "";
        style = "bg:#f5c2e7 fg:#11111b";
        format = "[@$hostname]($style)";
        ssh_only = false;
        disabled = false;
      };
      directory = {
        style = "bg:#f38ba8 fg:#11111b";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      directory.substitutions = {
        "Documents" = " ";
        "Downloads" = " ";
        "Music" = " ";
        "Pictures" = " ";
      };
      c = {
        symbol = " ";
        style = "bg:#e6657f fg:#11111b";
        format = "[ $symbol ($version) ]($style)";
      };
      docker_context = {
        symbol = " ";
        style = "bg:#e6657f fg:#11111b";
        format = "[ $symbol $context ]($style) $path";
      };
      git_branch = {
        symbol = "";
        style = "bg:#eb7c92 fg:#11111b";
        format = "[ $symbol $branch ]($style)";
      };
      git_status = {
        style = "bg:#eb7c92 fg:#11111b";
        format = "[$all_status$ahead_behind ]($style)";
      };
      golang = {
        symbol = " ";
        style = "bg:#e6657f fg:#11111b";
        format = "[ $symbol ($version) ]($style)";
      };
      nodejs = {
        symbol = "";
        style = "bg:#e6657f fg:#11111b";
        format = "[ $symbol ($version) ]($style)";
      };
      rust = {
        symbol = "";
        style = "bg:#e6657f fg:#11111b";
        format = "[ $symbol ($version) ]($style)";
      };
      time = {
        disabled = false;
        time_format = "%R"; # Hour:Minute Format
        style = "bg:#e05a75 fg:#11111b";
        format = "[ $time ]($style)";
      };
    };
  };
}
