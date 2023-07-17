




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

export use "${nuscripts}/modules/background_task/job.nu"
export use "${nuscripts}/modules/network/ssh.nu"
use "${nuscripts}/custom-completions/zellij/zellij-completions.nu" *
use "${nuscripts}/custom-completions/git/git-completions.nu" *
use "${nuscripts}/custom-completions/cargo/cargo-completions.nu" *
use "${nuscripts}/custom-completions/make/make-completions.nu" *
use "${nuscripts}/custom-completions/nix/nix-completions.nu" *

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

