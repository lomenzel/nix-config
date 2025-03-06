{ pkgs, inputs, ... }:
{
  imports = [ inputs.shabitica.nixosModules.default ];

  shabitica = {
    hostName = "deinniveau.rip";
    adminMailAddress = "leonard@menzel.lol";
    senderMailAddress = "habitica@menzel.lol";
    useSSL = false;
    useACME = false;
  };

}
