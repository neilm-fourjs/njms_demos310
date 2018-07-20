# njms_demos310
My Genero Demos updated for Genero 3.10 and legacy code removed.

The default user and log for the demo is:
test@test.com / 12test


The Demos:
* ipodTree - Tree demo
* picFlow - picFlow GDC
* wc_aircraft - Web Component - Interactive Images - Aricraft catering
* wc_amCharting - Web Component - Charting
* wc_googleMaps - Web Component - Google Maps
* wc_kite - Web Component - Interactive Image - SVG Kite
* widgets - Genero Widgets and UI features


The Application Framework:
* Login
* User Creation
* Menu System
* Basic table maintainance
* Order Entry
* Invoice printing
* Web Ordering


When deployed as via the gas the application urls will be:
* http://<server>/<gas-alias>/ua/r/<xcf>
or
* http://<server>:6394/ua/r/<xcf>

The xcf files are:
* njmdemo - Main demo with login using default GBC
* njmdemo_c - Main demo with login using a custom GBC
* njmdemo_t - Main demo with login using a custom teal GBC
* njmweb - Web Ordering demo using default GBC - dynamic form
* njmweb_c - Web Ordering demo using custom GBC - dynamic form
* njmweb_t - Web Ordering demo using custom teal GBC - dynamic form + csslayout
* njmweb2 - Web Ordering demo using default GBC - 'pagedScrollGrid'
* njmweb2_c - Web Ordering demo using custom GBC - 'pagedScrollGrid'
* njmdemodb - Create the demo database


Databases:
* Informix
* PostgreSQL
* Maria DB
* SQL Server


For PostgreSQL
        sudo -u postgres createuser <appuser>
        sudo -u postgres createdb njm_demo310
        sudo -u postgres psql
        psql (9.6.7)
        Type "help" for help.

        postgres=# grant all privileges on database njm_demo310 to <appuser>;
        GRANT
        postgres=# \q


For MariaDB added a user of 'dbuser' to connect to the database.
MariaDB [(none)]> CREATE USER 'dbuser'@'%';
MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'%';

