{
  lib,
  config,
  inputs ? throw "Pass inputs to specialArgs or extraSpecialArgs",
  ...
}:
{
  options = with lib; {
    nix.inputsToPin = mkOption {
      type = with types; listOf str;
      default = ["nixpkgs"];
      example = ["nixpkgs" "nixpkgs-master"];
      description = ''
        Names of flake inputs to pin
      '';
    };
  };

  config.nix = {
    registry = lib.listToAttrs (map (name: lib.nameValuePair name {flake = inputs.${name};}) config.nix.inputsToPin);
    nixPath = ["nixpkgs=flake:nixpkgs"];
    settings = {
      "flake-registry" = "/etc/nix/registry.json";
      channel.enable = false;
      allow-import-from-derivation = false;
      use-cgroups = true;
      connect-timeout = 5;
      extra-experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "auto-allocate-uids"
      ];
    };
  };
}
