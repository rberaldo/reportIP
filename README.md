# reportIP

A simple, yet fragile, script to email you a machine's IP.

It's one of my first scripts.

## Things that annoy me about it

`reportIP.sh` depends on your machine's ability to send emails. In my
case, I installed [ssmtp][ssmtp-deb] to let the script do its thing.
This was the easiest way I found to send emails from a script. It does,
however, require [some configuring][ssmtp-wiki].

I've also found that some implementations of `mail` won't play nice with
it. The following code doesn't work with the `mail` implementation
provided by the `mailx` package:

    echo -e "A new /tmp/ip.txt file was created @ "$HOSTNAME"\
      \nYour current IP is $IP" | mail -s "IP report" "$EMAIL_ADDR" || { \
        # or (||), if mail fails, exit with error code > 0 and schedule to run
        # again in 30 minutes
        echo "$(pwd)/$(basename $0)" | at now + 30 minutes 2> /dev/null;
        echo "Running again in 30 minutes"; 
        exit 1; }

I haven't done extensive research as to the reason why this happens, but
apparently it's because the implementation of `mail` provided by `mailx`
doesn't exit with an error code when it fails to send an email.
