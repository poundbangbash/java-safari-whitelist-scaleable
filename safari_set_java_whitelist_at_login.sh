#!/bin/sh
## Edits
## --------
## 10-31-13 
## --------
## Created server array and for loop to iterate thru the list of servers instead of listing them out individually
##
## --------
## 11/8/13
## --------
## Added Safari version check to make sure it doesn't run on versions >=6.1


# Get today's date
TODAY=$(/bin/date "+%FT%TZ")

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Determine Safari version
SAFARIVERSION=$(defaults read /Applications/Safari.app/Contents/Info CFBundleShortVersionString)
SAFARIDOTVERSION=$(echo ${SAFARIVERSION} | cut -f 2 -d .)

SERVERS=( "SERVER.EXAMPLE.COM" "SERVER2.EXAMPLE.COM" "SERVER3.EXAMPLE.COM" )

if [[ $SAFARIDOTVERSION -gt 0 ]]; then
    /usr/bin/logger "Unsupported version of Safari: ${SAFARIVERSION}.  Version must be <6.1"
else
    # Get Java plug-in info
    JAVA_PLUGIN=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`

    if [[ ${osvers} -ge 6 ]]; then
        for MYSERVER in "${SERVERS[@]}"
        do
            # Check com.apple.Safari.plist for Server address
            SERVER_WHITELIST_CHECK=`/usr/bin/defaults read $HOME/Library/Preferences/com.apple.Safari WhitelistedBlockedPlugins | grep PluginHostname | awk '{print $3}' | grep $MYSERVER | tr -d '";'`
                if [[ -n ${SERVER_WHITELIST_CHECK} ]]; then

                    # Server settings are present
                    /usr/bin/logger "${SERVER_WHITELIST_CHECK} is part of the Java whitelist in Safari. Nothing to do here."
                else            
                    # Add Server to Java whitelist
                    /usr/bin/defaults write $HOME/Library/Preferences/com.apple.Safari "WhitelistedBlockedPlugins" -array-add '{"PluginHostname" = "'$MYSERVER'"; "PluginIdentifier" = "'$JAVA_PLUGIN'"; "PluginLastVisitedDate" = "'$TODAY'"; "PluginName" = "Java Applet Plug-in"; "PluginPageURL" = "https://'$MYSERVER'"; "PluginPolicy" = "PluginPolicyNeverBlock";}'
                    /usr/bin/logger "$MYSERVER has been added to the Java whitelist in Safari."
                fi
        done
    fi
fi

exit 0