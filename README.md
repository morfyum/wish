# WINDOWS IMAGING SHELL (WISH)

## Core Directories
- `service`: Example samba container
    - If you want to use it check before:
        - Your Firewall rules
        - StartService.sh configuration like password
        - Your Security Policy
- `shared`: This whole drive will be shared by `samba` service
    - This is the core directory of **WISH**
    - `shared/DRIVERS`: Place of drivers separated by Manufacturers
        - EXAMPLE: `shared/DRIVERS/Latitude 5400/<extracted_driver_.cab_or_.exe>`
        - wish can create automatically the Manufacturer directory under the DRIVERS.  
    - `shared/extensions`: You can place here any non-core / Third-party tool
        - EXAMPLE: 
            - `shared/extensions/ShowKeyPlus/<show_key_plus_exe>`
            - `shared/extensions/ShowKeyPlus/start_show_key_cmd>`
    - `shared/ISO`: Location of exracted ISO files.
    - `shared/logs`: WISH logs.
    - `shared/logs/wish.log`: All ERROR/CRITICAL messages that make operation impossible  
    - `shared/postInstall`: Place postInstall scripts and tools here.
    - `shared/src`: wish.ps1 and core dependencies 
    - `shared/startWish.cmd`: Should launch this by `startnet.cmd`
- `startnet`: startnet tools and scripts 
### Directory Tree
```sh
.
├── service
│   ├── firewall-cmd.sh 
│   ├── restore-config.sh
│   └── startService.sh
├── shared
│   ├── DRIVERS
│   │   └── Dell Inc
│   ├── extensions
│   │   └── acpi
│   ├── ISO
│   │   └── Win11_25H2_Hungarian_x64
│   ├── logs
│   │   ├── units
│   │   ├── wish.log
│   ├── postInstall
│   │   ├── postInstallLauncher.cmd
│   │   └── postInstall.ps1
│   ├── src
│   │   ├── Config.json
│   │   ├── diskpart.txt
│   │   ├── logging
│   │   ├── unattend.xml
│   │   ├── utils.ps1
│   │   ├── wish.ps1
│   │   └── worksheet_template.json
│   └── startWish.cmd
└── startnet
    ├── wifiConnect.cmd
    ├── wifiTemplate.xml
    └── wifi.xml
```