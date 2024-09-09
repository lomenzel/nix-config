{ pkgs, inputs, ... }:
{
  imports = [ inputs.shabitica.nixosModules."x86_64-linux".default ];

  shabitica = {
    hostName = "deinniveau.rip";
    adminMailAddress = "leonard@menzel.lol";
    senderMailAddress = "habitica@menzel.lol";
    useSSL = true;
  };

}
