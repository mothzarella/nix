{pkgs, ...}: {
  home = {
    username = "tar";
    homeDirectory = "/home/tar";
    stateVersion = "25.11";

    packages = with pkgs; [
      brightnessctl

      vivaldi

      claude-code
      jetbrains.pycharm-community
    ];
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "monospace:size=11";
      };
      colors.alpha = "0.95";
    };
  };

  programs.fuzzel = {
    enable = true;
    settings.main = {
      terminal = "foot";
      font = "monospace:size=11";
    };
  };

  xdg.configFile."niri/config.kdl".text = ''
    // Verifica il nome con: niri msg outputs
    output "eDP-1" {
        mode "1920x1080@60.000"
        scale 1.0
    }

    debug {
        // renderD129 = NVIDIA (seconda GPU), verificare con: ls -la /dev/dri/
        render-drm-device "/dev/dri/renderD129"
    }

    input {
        keyboard {
            xkb {
                layout "it"
            }
        }
        touchpad {
            tap
            natural-scroll
        }
    }

    binds {
        Mod+Return { spawn "foot"; }
        Mod+D { spawn "fuzzel"; }
        Mod+Q { close-window; }
        Mod+Shift+E { quit; }

        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+Shift+1 { move-window-to-workspace 1; }
        Mod+Shift+2 { move-window-to-workspace 2; }
        Mod+Shift+3 { move-window-to-workspace 3; }
        Mod+Shift+4 { move-window-to-workspace 4; }

        Mod+F       { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86MonBrightnessUp   { spawn "brightnessctl" "set" "+10%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "10%-"; }
    }

    spawn-at-startup "uwsm" "finalize"
  '';
}
