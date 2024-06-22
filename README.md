# iocage-plugin-BookStack-ngx

Artifact files for BookStack-ngx iocage plugin

site: https://www.bookstackapp.com/
github: https://github.com/BookStackApp/BookStack/blob/development/readme.md

The plugin script will install BookStack-ngx version 24.05.2 from official release 

#### To install:

- ssh to your TrueNAS or open **Shell** in Web UI
- download plugin `fetch https://raw.githubusercontent.com/hellvesper/iocage-plugin-bookstack-ngx/master/bookstack-ngx.json`
- launch installation `iocage fetch -P bookstack-ngx.json -n bookstack` where `bookstack` - your plugin jail name.
    choose jail name carefully, it will your mDNS domain, like `bookstack` -> `http://bookstack.local`


After installation you can open BookStack-ngx using ip address or mDNS domain address which will equal jail name. For example above mDNS address will be `http:/bookstack.local`

#### Note

Plugin configured to use `DHCP`, so it will acquire new `IP` address from you router which will differ from your **NAS** IP


#### Description

BookStack is an opinionated documentation platform that provides a pleasant and simple out-of-the-box experience. New users to an instance should find the experience intuitive and only basic word-processing skills should be required to get involved in creating content on BookStack. The platform should provide advanced power features to those that desire it but they should not interfere with the core simple user experience.

BookStack is not designed as an extensible platform to be used for purposes that differ to the statement above.

In regard to development philosophy, BookStack has a relaxed, open & positive approach. At the end of the day this is free software developed and maintained by people donating their own free time.

You can read more about the project and its origins in our FAQ here.