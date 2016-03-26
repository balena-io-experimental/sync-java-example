### A Java 8 resin sync example:


>Note: Currently this will only work on the Raspberry Pi 2 and 3, BeagleBone Black, and in general ARMv7 devices. Other devices (like the rpi1) will not work due to the architecture of the base image. We will be addressing this limitation before wider release.

This example will allow you to develop quickly on a resin.io device by avoiding the build/download process and directly syncing a folder to a "test" device in the fleet.

> **NB:** You need Oracle JDK 8 installed on your Development Machine, because the java code will be compiled on your Dev machine.

In order to get this new super power you will need to set up a few things on your development computer.

>**NOTE:** This example assumes you are familiar with the basic resin.io workflow and have set up a device and can comfortably push code to it. If you are new to resin.io first have a look at our [getting started guide](http://docs.resin.io/#/pages/installing/gettingStarted.md).

##### Install the Plugin
resin-sync depends on the following:
* node.js > 4.0
* resin-cli > 2.6.0

To setup resin-sync first clone the resin-sync repo to your local machine:
`git clone https://github.com/resin-io/resin-plugin-sync.git`

Now change into the resin-plugin-sync directory and use npm install to it globally:
```
cd resin-plugin-sync
sudo npm install -g
```

To check that the plugin is properly installed login with the resin-cli:
```
shaun@shaun-desktop:~$ resin login
______          _         _
| ___ \        (_)       (_)
| |_/ /___  ___ _ _ __    _  ___
|    // _ \/ __| | '_ \  | |/ _ \
| |\ \  __/\__ \ | | | |_| | (_) |
\_| \_\___||___/_|_| |_(_)_|\___/

Logging in to resin.io
? How would you like to login? (Use arrow keys)
❯ Web authorization (recommended)
  Credentials
  Authentication token
  I don't have a Resin account!
```

Now run `resin help --verbose` to see if the plugin is enabled. You should see `sync <uuid>` at the bottom:
```
shaun@shaun-desktop:~$ resin help --verbose
Usage: resin [COMMAND] [OPTIONS]

Run the following command to get a device started with Resin.io

  $ resin quickstart

If you need help, or just want to say hi, don't hesitate in reaching out at:

  GitHub: https://github.com/resin-io/resin-cli/issues/new
  Gitter: https://gitter.im/resin-io/chat

Primary commands:

    help [command...]                   show help                          
    quickstart [name]                   getting started with resin.io      
    login                               login to resin.io                  
    app create <name>                   create an application              
    apps                                list all applications              
    app <name>                          list a single application          
    devices                             list all devices                   
    device <uuid>                       list a single device               
    logs <uuid>                         show device logs                   

Installed plugins:

    sync <uuid>                         sync your changes with a device    

Additional commands:
```

##### Setting up the Development Device

Now that you have the resin-cli and resin-sync plugin installed, you need to setup the device-side. This is pretty straightforward and only requires these 2 steps:
1. Enable the deviceURL for the device which you want to use as your development device. This can be done from the `Actions` tab on the device page. If you need help with this, have a look at our [docs on DeviceURLs](http://docs.resin.io/#/pages/management/devices.md#enable-public-device-url).
2. Add an environment variable to the device called AUTH_TOKEN. The value of this variable should be your Auth token found on the preferences page. If you are unsure of how to set a device environment variable check our [docs on Env Vars](http://docs.resin.io/#/pages/management/env-vars.md)
3. Push this repo (sync-java-example) to your resin.io application.

Once the device has pulled the first update and is in the Idle state, you will be ready to start using resin-sync to really speed up your resin.io development.

>** Warning: ** The Auth Token will expire in a month or slightly longer, so you will need to refresh it.

##### Using resin-sync

Now that your device is setup, make some small changes to the java code in `app/` folder and run `resin sync <UUID>` from within the `sync-java-example` directory. Replace `<UUID>` with the 7 digit alphanumeric id shown on the device dashboard. Here is an example:
```
shaun@shaun-desktop:~/Desktop/sync-java-example$ resin sync 510b43d
Connecting with: 510b43d
I will run before syncing to the device...
sending incremental file list
main.js
             36 100%    0.00kB/s    0:00:00 (xfr#1, to-chk=0/2)
Synced, restarting device
```
In about 30seconds, your new Java code should be running on the development device.

>**Note:**  If you need to install dependencies with something like `apt-get install`, then you will still need to go through the build pipeline and do a regular `git push resin master`. Once it is complete, you can resume using resin sync to develop.

##### What is resin-sync.yml
The resin-sync.yml file is a handy file that allows you to describe the behaviour of resin-sync for this repo. In this example it looks like this:
```
source: app/
before: 'javac app/Hello.java'
ignore:
    - .git
    - Dockerfile
    - resin-sync.yml
progress: true
watch: false
```
Here is a short description of what the fields do:

**source:** This defines the directory that will be synced to the device. This will always be synced to `/usr/src/app` on the target device (in the future this will be configurable). In our example we sync our local `app/` directory to `/usr/src/app` so all our java binaries gets synced across.

**before:** The `before` command, allows us to define a pre-sync action, this is useful for compiled languages like go-lang or Java, where we could have this command execute a local cross-compile and then only sync over the binaries that are produced. In this example we have our local machines JDK 8 compile the java and then sync it across to the device. **NB** you need the JDK 8 installed on you development computer. Here you could even use a tool like `make` to handle the build process and just call it from `--before`.

**ignore:** The `ignore` command allows you to list files and directories that resin-sync should ignore when syncing to the device. In this example we ignore `.git`, even though this is strictly not necessary because there is no `.git ` in the `app/` directory we are syncing.

**progress:** This command lets you see which files are being synced across and how fast that is happening. Its mainly useful for debugging and checking what is actually going on.

**watch:** This command allows you to set the resin-sync plugin to continually watch a directory and sync files every time something is changed and saved. **NOTE:** If you do a couple of rapid saves, it will try sync while the container on the device is still restarting, and you will see some errors.

For a more comprehensive list of resin sync commands, run `resin help sync`

##### Some Extra Info

Resin-sync works by setting up an ssh server on the device that listens on port 80. The code is then synced over the resin.io VPN to the device. This means you can use resin-sync even with remote devices anywhere in the world.

It also means you will have ssh automatically set up for you if you want to run some test commands. Just run `ssh root@<DEVICE-IP> -p80`. By default the device side container will pull all the public ssh keys onto the device, so you will not need a password. But if you ssh key is not on the device, then you can access the ssh with the password: `resin`.

##### Current Limitations

Currently the sync can only be done to the `/usr/src/app` directory of the device. Have a look at the base image to see why. [[link](https://github.com/resin-io-library/base-images/pull/49/files#diff-90358446892ac0a322643ed27595fbd9R12)]

Currently there is also a case that if you sync some changes, roll back those change and then commit and push...then you will notice that the synced changes are still running. This is again due to the section of code above. It is recommended that you do a purge of /data on your device before you run the git push.

The security model of resin sync is not yet fully complete, but so long as your development device doesn't fall into a potential attacker's hands, you should not have any issues. This is another thing we're working on improving before full release.
