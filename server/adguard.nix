{ secrets, pkgs, config, ...}: {
   services.adguardhome = {
    enable = true;
    settings = {
      dns = {
        upstream_dns = [
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        save_search.enabled = false;

      };
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
      ];
    };
    port = 3456;
   };
}