DuckDNS IP Updater
=======

Create a file called "duckdns.cfg" in the same directory as duckdns_upd_ip.sh that contains your DOMAINS and TOKEN. For example:

    #duckdns.cfg
    DOMAINS="example1,example2"
    TOKEN="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx"
    # Uncomment this line to not validate SSL certificates (less secure)
    #NO_CERT=1
    # How many times to retry to get the current IP Addres (Default=0)
    #MAXRETRIES=2


Then, schedule the duckdns_upd_ip.sh file to run on a regular basis via cron
