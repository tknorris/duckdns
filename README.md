duckdns
=======

Create a file called "duckdns.cfg" in the same directory as duckdns_upd_ip.sh that contains your DOMAINS and TOKEN. For example:

    #duckdns.cfg
    DOMAINS="example1,example2"
    TOKEN="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx"


Then, schedule the duckdns_upd_ip.sh file to run on a regular basis via cron
