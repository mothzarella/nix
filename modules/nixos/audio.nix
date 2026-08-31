{
  flake.modules.nixos.audio = {pkgs, ...}: {
    security.rtkit.enable = true;

    services = {
      pulseaudio.enable = false;

      pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };

        extraConfig = {
          pipewire."92-low-latency" = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.quantum" = 256;
              "default.clock.min-quantum" = 256;
              "default.clock.max-quantum" = 256;
            };
          };

          pipewire-pulse."92-low-latency"."pulse.properties" = {
            "pulse.min.req" = "256/48000";
            "pulse.default.req" = "256/48000";
            "pulse.min.quantum" = "256/48000";
            "pulse.max.quantum" = "256/48000";
          };
        };

        wireplumber.extraConfig = {
          "10-bluez" = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              "bluez5.roles" = [
                "hsp_hs"
                "hsp_ag"
                "hfp_hf"
                "hfp_ag"
              ];
            };
          };

          "99-disable-suspend" = {
            "monitor.alsa.rules" = [
              {
                matches = [
                  {"node.name" = "~alsa_input.*";}
                  {"node.name" = "~alsa_output.*";}
                ];
                actions.update-props."session.suspend-timeout-seconds" = 0;
              }
            ];
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pavucontrol
      pwvucontrol
      wireplumber
    ];
  };
}
