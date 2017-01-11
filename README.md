# Docker image with Minecraft (Spigot server) & Overviewer (Mapping)

This docker image builds and runs the spigot version of minecraft. It deploys overviewer within the same container to view your minecraft map.

![Image of a minecraft overworld map rendered in overviewer showing player locations](http://i.imgur.com/846ALCA.png)

All credit to [nimmis](https://github.com/nimmis). This image build upon their work and haphazidly adds overviewer plus some automation. Please see their [README.md](https://github.com/nimmis/docker-spigot) for more info.

### What's included?

- [Spigot](https://www.spigotmc.org) Minecraft server.
    - The latest version is downloaded upon first run.
- [Overviewer](https://overviewer.org/) mapping.
    - Player locations shown by default
    - In-game [signs](http://minecraft.gamepedia.com/Sign) with the first row of text set to "!" can be shown or hidden.
- Automatic Overviewer map refreshes every 30 mins, with player locations and signs every 10 minutes.
    - To be clear, player locations are not real time.
- Automatic Minecraft world backups.
    - Saved to a tar.gz file, must be manually exported from the container.

### Generating the container for the first time.

**This is important and you only need to do it once.**

1) You need your own Google Maps API key. Click this link: https://developers.google.com/maps/documentation/javascript/get-api-key and follow the instructions.

2) [Install docker](https://docs.docker.com/engine/installation/)

3) Clone this repo and then run:

        docker build -t docker_spigot_overviewer .
	
4) Subsitute these values into the command below.
    
- Add your key to:
    
    - `GOOGLE_MAPS_KEY=<--replace with your google maps key-->`, for example, `GOOGLE_MAPS_KEY=abcdefg-H1J2Lm4PQ-dscasdwqeqweb321321Jn`.
	
- Specify how much memory the minecraft server can utilise
    
    - `MC_MAXMEM=<--megabytes-->m`, for example, `MC_MAXMEM=1500m`
	
        or
	
    - `MC_MAXMEM=<--gigabytes-->g`, for example, `MC_MAXMEM=4g`

When ready, run:

`docker run -d -p 25565:25565 -p 80:80 -e EULA=true -e MC_MAXMEM=<--replace with megabytes-->m -e GOOGLE_MAPS_KEY=<--replace with your google maps key--> --name mcserver docker_spigot_overviewer`

Further information about the docker run command: 

|Argument|Description|
|---|---|
|`-p 25565:25565`|Required. Opens the port minecraft uses for gameplay|
|`-p 80:80`|Required. Opens the http port so you can access Overviewer|
|`-e GOOGLE_MAPS_KEY=<--replace with your google maps key-->`|Required. You must add your own API key (which you can obtain from the link above) other overviewer **will not work**.
|`-e EULA=true`|Required. By adding arguemnt this you're accepting the [Minecraft EULA](https://account.mojang.com/documents/minecraft_eula).|
|`-e MC_MAXMEM=<--megabytes-->m`|Sets the maximum memory to use <size>m for Mb or <size>g for Gb, if this parameter is not set 1 Gb is chosen.
|`--name mcserver`|Names this docker container 'mcserver' so it's easier to address later.|

### First time run

The first run will take a couple of minutes depending on computer and network speed. It pulls down the latest version of BuildTools and builds a spigot.jar from the selected minecraft version. This is done in numerous steps so please be patient. 

You can follow the output from the compilation with the command:

	# docker logs -f mcserver

    *** open logfile
    *** Run files in /etc/my_runonce/
    *** Running /etc/my_runonce/set_timezone...
    *** Run files in /etc/my_runalways/
    *** Running /etc/my_runalways/do_build_spigot...
    --2016-12-04 13:17:37--  https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
    Resolving hub.spigotmc.org (hub.spigotmc.org)... 104.27.195.96, 104.27.194.96, 2400:cb00:2048:1::681b:c360, ...
    Connecting to hub.spigotmc.org (hub.spigotmc.org)|104.27.195.96|:443... connected.
    HTTP request sent, awaiting response... 200 OK

When the compilation is complete your minecraft server will start and you will see something like:

    *** Log: Success! Everything compiled successfully. Copying final .jar files now.
    *** Log: Copying craftbukkit-1.11-R0.1-SNAPSHOT.jar to /minecraft/build/.
    *** Log:   - Saved as craftbukkit-1.11.jar
    *** Log: Copying spigot-1.11-R0.1-SNAPSHOT.jar to /minecraft/build/.
    *** Log:   - Saved as spigot-1.11.jar
    *** Running /etc/my_runalways/eula...
    *** Running /etc/rc.local...
    *** Booting supervisor daemon...
    *** Supervisor started as PID 4820
    *** Started processes via Supervisor......
    crond                            RUNNING    pid 4824, uptime 0:00:03
    spigot                           RUNNING    pid 4825, uptime 0:00:03
    syslog-ng                        RUNNING    pid 4823, uptime 0:00:03

Exit the log by pressing CTRL-C.


## Starting & Stopping

After the inital run you can start and stop the entire container via:

	docker start mcserver
	docker stop mcserver


## Useful Commands

### Logs 
To get details of the latest events from the minecraft spigot server type

	docker exec mcserver mc_log

and you will be shown the latest logs, which will continue to update. For example:

	Abort with CTRL-C
	[13:02:15 INFO]: Zombie Aggressive Towards Villager: true
	[13:02:15 INFO]: Experience Merge Radius: 3.0
	[13:02:15 INFO]: Preparing start region for level 0 (Seed: 506255305130990210)
	[13:02:16 INFO]: Preparing spawn area: 22%
	[13:02:17 INFO]: Preparing spawn area: 99%
	[13:02:17 INFO]: Preparing start region for level 1 (Seed: 506255305130990210)
	[13:02:18 INFO]: Preparing spawn area: 95%
	[13:02:18 INFO]: Preparing start region for level 2 (Seed: 506255305130990210)
	[13:02:18 INFO]: Server permissions file permissions.yml is empty, ignoring it
	[13:02:18 INFO]: Done (3.650s)! For help, type "help" or "?"

Exit the log by pressing CTRL-C.

To get details of the latest events from the overviewer processes type

	docker exec mcserver ov_log

For example:

    Abort with CTRL-C
    20170109 22:05:01 INFO] STARTING ov_render
    20170109 22:05:01 INFO] Updating map POIs...
    2017-01-09 22:05:01  Looking for entities in <RegionSet regiondir='/minecraft/world/region'>
    2017-01-09 22:05:12  Done.
    2017-01-09 22:05:12  Loaded UUID cache from '/usr/share/nginx/html/uuidcache.dat' with 7 entries
    2017-01-09 22:05:12  Done handling POIs
    2017-01-09 22:05:12  Writing out javascript files
    2017-01-09 22:05:12  Wrote UUID cache with 7 entries
    2017-01-09 22:05:12  Done
    20170109 22:05:12 INFO] Map POI update complete!


### Sending commands to the Minecraft server console

Use the mc_send command to send minecraft server console commands. For example:

	docker exec mcserver mc_send "time set day"
	
And the output:

	[13:02:15 INFO]: Zombie Aggressive Towards Villager: true
	[13:02:15 INFO]: Experience Merge Radius: 3.0
	[13:02:15 INFO]: Preparing start region for level 0 (Seed: 506255305130990210)
	[13:02:16 INFO]: Preparing spawn area: 22%
	[13:02:17 INFO]: Preparing spawn area: 99%
	[13:02:17 INFO]: Preparing start region for level 1 (Seed: 506255305130990210)
	[13:02:18 INFO]: Preparing spawn area: 95%
	[13:02:18 INFO]: Preparing start region for level 2 (Seed: 506255305130990210)
	[13:02:18 INFO]: Server permissions file permissions.yml is empty, ignoring it
	[13:02:18 INFO]: Done (3.650s)! For help, type "help" or "?"
	[13:12:35 INFO]: Set the time to 1000

This will show you the server's response to your command. For a full list of commands check the official [wiki](http://minecraft.gamepedia.com/Commands#Summary_of_commands). Exit the log by pressing CTRL-C.

## Starting and stopping the minecraft server

To stop the minecraft server inside the container run

	docker exec mcserver mc_stop

To start it after being stopped:

	docker exec mcserver mc_start

Finally to restart it:

	docker exec mcserver mc_restart
