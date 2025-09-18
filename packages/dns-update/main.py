from INWX.Domrobot import ApiClient
import requests
import dns.resolver
import os

INWX_PASSWORD_FILE = os.environ["INWX_PASSWORD_FILE"]
INWX_USERNAME_FILE = os.environ["INWX_USERNAME_FILE"]
HOSTS_FILE = os.environ["HOSTS_FILE"]

with open(INWX_PASSWORD_FILE, "r") as f:
    INWX_PASSWORD = f.read().strip()

with open(INWX_USERNAME_FILE, "r") as f:
    INWX_USERNAME = f.read().strip()

with open(HOSTS_FILE, "r") as f:
    HOSTS = f.read().strip().split("\n")


ipv6 = requests.get("https://api6.ipify.org").text.strip()


def domain_name(host):
    return ".".join(host.strip().split(".")[-2:])

def needs_update(host):
    try:
        answers = dns.resolver.resolve(host, "AAAA")
        current_dns = answers[0].to_text()
    except dns.resolver.NoAnswer:
        current_dns = None
    except dns.resolver.NXDOMAIN:
        current_dns = None
    if current_dns != ipv6:
        print(host, "(", current_dns, ") needs update to", ipv6)
    return current_dns != ipv6

to_update = list(filter(needs_update, HOSTS))

if not to_update:
    print ("no updates needed")
    exit(0)

api = ApiClient("https://api.domrobot.com")
api.login(INWX_USERNAME, INWX_PASSWORD)

for host in to_update:
    print("### Going to update", host)
    print(domain_name(host))
    resp = api.call_api(api_method="nameserver.info", method_params= {"domain": domain_name(host)})
    # print( "resp:", resp)

    if "resData" not in resp or "record" not in resp["resData"]:
        print("ERROR: ### skipping", host, "— no record data returned")
        continue

    record_id = None
    skip_host = False
    for r in resp["resData"]["record"]:
        if (r["name"] == host and r["type"] == "AAAA"):
            record_id = r["id"]
            if r["content"] == ipv6:
                print("### skiping", host, "because the dns entry seems to be correct")
                skip_host = True
            break

    if skip_host:
        continue

    if record_id is None:
        print ("creating record for", host)
        api.call_api(api_method="nameserver.createRecord", method_params={
            "domain": domain_name(host),
            "name": host,
            "content": ipv6,
            "ttl": 300,
            "type": "AAAA",
        })
    
    else:
        api.call_api(api_method= "nameserver.updateRecord", method_params = {
            "id": record_id,
            "content": ipv6,
        })


    print("### finisched updating", host)


api.logout()
print ("everything done, exiting now.")
exit(0)