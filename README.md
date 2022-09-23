# Linuxbox-Setup Script

## Overview

`Linuxbox-Setup` is a shell script that aims to facilitate the installation of indispensable packages for some users (mostly developers) in a fresh install of a Debian-based Linux distro. The `Linuxbox-Setup` supports packages from different sources and formats: executables, Debian packages, custom PPA sources, and official PPA sources.

## Packages

All packages you want to install must be present in the [package.json](package.json) file. These packages are classified into the following categories: 
- **packages** - For executables, self-installation scripts, and debian packages. 
- **custom-ppa-repositories** - For custom PPA Debian packages sources.

The table below presents the attributes necessary to construct your package.json file:
  
| Property         | Type     | Description                                                                     |
| ---------------- | :------: | ------------------------------------------------------------------------------- |
| package          | String   | The official package name                                                       |
| url              | String   | The release page or direct download link URL                                    |
| executable       | String   | The name of the executable (binary) for the package                             |
| metadata         | String   | Metadata information                                                            |
| direct-link      | Boolean  | Indicates if the URL provided refers to a direct link or a release page         |
| release-name     | String   | The release name as it appears on the release page or on the APT's package name |
| type             | String   | Can be `DEB` for Debian packages or `BINARY` for portable executables packages  |
| gpg-url          | String   | GPG URL                                                                         |
| ppa-url          | String   | Custom PPA URL                                                                  |
| distribution     | String   | The distribution name, release code name or class                               |
| categories       | Array    | DFSG compliance categories

The [package.json](package.json) file must be structured like the code snippet below. It is important to note that in the case of **GitHub releases**, you need to point the URL to the GitHub API releases URL as `https://api.github.com/repos/{username}/{repository}/releases/latest`.

```json
{
    "packages": {
        "sublime-text": {
            "url": "https://www.sublimetext.com/download_thanks?target=x64-deb",
            "executable": "subl",
            "metadata": {
                "direct-link": false,
                "release-name": "sublime-text",
                "type": "DEB"
            }
        },
        "docker-compose": {
            "url": "https://api.github.com/repos/docker/compose/releases/latest",
            "executable": "docker-compose",
            "metadata": {
                "direct-link": false,
                "release-name": "docker-compose-Linux-x86_64",
                "type": "BINARY"
            }
        }
    },
    "custom-ppa-repositories": {
        "docker-ce": {
            "gpg-url": "https://download.docker.com/linux/ubuntu/gpg",
            "ppa-url": "https://download.docker.com/linux/ubuntu",
            "distribution": "focal",
            "categories": ["stable"],
            "executable": "docker"
        }
    }
}
```

## Instructions

In order to use `Linuxbox-Setup` script just clone this repository and as superuser, execute the main script as shown below:

```bash
git clone --depth=1 https://github.com/leuras/linuxbox-setup.git
cd linubox-setup
sudo ./setup
```

