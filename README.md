```
                  ___.        .___          ___.                 
    __  _  __ ____\_ |__    __| _/_______  _\_ |__   _______  ___
    \ \/ \/ // __ \| __ \  / __ |/ __ \  \/ /| __ \ /  _ \  \/  /
     \     /\  ___/| \_\ \/ /_/ \  ___/\   / | \_\ (  <_> >    < 
      \/\_/  \___  >___  /\____ |\___  >\_/  |___  /\____/__/\_ \
                 \/    \/      \/    \/          \/            \/
61 6B 69 74 61 6F 6E 72 61 69 6C 73 40 43 6F 64 65 4D 69 6E 65 72 34 32 

```

[![WebDevBox DemoTEXT](https://github.com/akitaonrails/webdevbox/raw/main/helpers/intro.png)](https://player.vimeo.com/video/805780923?h=ddd98118f0 "WebDevBox Demo")

## Distrobox WebDevBox

This is an Archlinux based Docker image that comes pre-installed with
everything I think a web developer would need in the 2020s. Every language, every tool, every helper.

Take a look at the [Dockerfile](Dockerfile) to see all packages, but in summary:

* ZSH (of course) with several plugins
* Chezmoi to sync your dotfiles
* LunarVim already configured to work with TMUX
* All major languages (Ruby, Nodejs, Python, PHP, Kotlin, etc)
* ASDF so you can install specific old language versions for your projects
* Podman by default, and every Devops tool (K8S, Skaffold, Helm, Terraform, etc)
* All the normal debug tools (lsof, strace, etc)

## Usage

First, install Podman in your OS (Docker works fine as well), for example, in Arch:

    $ sudo pacman -S podman

Install Distrobox. I tried the "distrobox-git" package in AUR, but Distrobox is still in heavy development and I stumbled upon a old bug that was already solved in the main branch, so I recommend installing the "unstable" version manually:

    $ curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh -s -- --next

Now you have 2 options. The easy one is to just pull the image from DockerHub:

    $ podman pull docker.io/akitaonrails/webdevbox:latest

Or you can customize the Dockerfile and build it manually:

    $ git clone https://github.com/akitaonrails/webdevbox.git
    $ cd webdevbox
    $ podman build . -t akitaonrails/webdevbox

Finally, it's normal Distrobox usage. Let's create the box and enter in it:

    $ mkdir -p ~/.local/share/distrobox/webdevbox
    $ distrobox create 
      -i akitaonrails/webdevbox \
      -n webdevbox-demo -I \
    $ distrobox enter webdevbox-demo

*WARNING:* Distrobox maps its internal home directory directly on top of your real home by default. It will automatically create a user with the same username as you are using right now,
so it should be very seamleass to transition between them. But be careful that whatever destructive command you run over your home files, will be
permanent. If you prefer not to expose your home directory directly, you can point the internal home to somewhere else, like this:

    $ distrobox create 
      -i akitaonrails/webdevbox \
      -n webdevbox-demo -I \
      -H ~/.local/share/distrobox/webdevbox \
      --volume $HOME:/mnt/host

I prefer to map to a new directory and have a separated home per box. Then map my home as an external drive in "/mnt/host".

Then we can initialize [Chezmoi](https://www.chezmoi.io/). I'd recommend first forking my [dotfiles repository](https://github.com/akitaonrails/dotfiles), but let's use it as example:

    $ chezmoi init https://github.com/akitaonrails/dotfiles
    $ chezmoi update

It will prompt you for your specific information such as preferred Git email. I configured Tmux to have the key bind "Ctrl+Alt+n" to open a new pane directly to a text file to serve as a shortcut for times when you want to make quick notes or add reminders. I usually point to my Dropbox synced Obsidian directory, for example.

And if you want to run Podman inside Distrobox (yes! you can run a new container inside another container, Podman is already configured to run rootless inside), and if you chose
to map your home directory directly to your real home, then make sure to create the volume for the containers:

    $ mkdir -p $HOME/.local/share/containers/storage/

Whenever you `podman pull` inside the Box, the blobs will be stored there, so not to bloat the box itself. Remember that changes made inside the box are persistent.

And that's it. You can start working!

## FAQ

### Did you configure Git Aliases?

Yes, type `git la` to have a list of all the built-in aliases

### How can I see Tmux shortcuts?

Type "Ctrl+b" and "?" to open a short (incomplete) list. But reading the ".tmux.conf" file is easier.

### How do I navigate in Tmux?

The navigation key binding were customized. The same Ctrl+[hjkl] are used to navigate between
both Tmux panels and LunarVim panels.

I also configured navigaton in copy mode to be like Vim (hjkl). Get used to the Vi style of using "hjkl" instead of arrow keys.

Do read [.tmux.conf](https://github.com/akitaonrails/dotfiles/blob/main/dot_tmux.conf.tmpl) from my dotfiles repo.

### Did you customize LunarVim?

LunarVim is mostly stock. I did add a few plugins such as GitHub CoPilot and ChatGPT.

Do read [config.lua](helpers/config.lua), and go to the bottom of the file to see what I changed.

### Why didn't you install virtualenv, nvm or rvm?

Because the box comes with the much superior [ASDF](https://asdf-vm.com/guide/getting-started.html).

### Why did you install the pacman language packages if you installed ASDF?

The best practice is to have the native packages in the OS do their job. Only configure custom language versions from asdf per project. For example:

    $ cd my_project
    $ asdf install ruby 2.6.0
    $ asdf local ruby 2.6.0

Now only this project directory responds to the specific obsolete Ruby 2.6.

### Why Chezmoi to manage dotfiles?

Because it felt simple. You should always edit dotfiles in the `~/.local/share/chezmoi` directory and add information specific to your machine in `~/.config/chezmoi/chezmoi.toml`.

If you created a new dotfile, add it to the repository:

    $ chezmoi add --autotemplate .fishrc

If you changed some file in the `local/share` directory, update your real files with:

    $ chezmoi update

When everything is working, push to your fork of my dotfiles with:

    $ chezmoi cd
    $ git add . ; git commit -m "description" ; git push origin main
    $ exit

Read [their documentation](https://www.chezmoi.io/)

### What are the largest installed packages?

This is why I chose not to install Postman (~300MB), Azure-Cli (~600MB), Google Cloud SDK (600MB). You can install them inside the box anyway. But damn, Rust is heavy!

```
❯ yay -Ps
==> Yay version v11.3.2
===========================================
==> Total installed packages: 558
==> Foreign installed packages: 10
==> Explicitly installed packages: 83
==> Total Size occupied by packages: 4.8 GiB
==> Size of pacman cache /var/cache/pacman/pkg/: 30.0 MiB
==> Size of yay cache /home/akitaonrails/.local/share/distrobox/webdevbox/.cache/yay: 0.0 B
===========================================
==> Ten biggest packages:
rust: 526.4 MiB
insomnia-bin: 394.9 MiB
jdk11-openjdk: 322.2 MiB
chromium: 277.2 MiB
go: 195.6 MiB
gcc: 171.3 MiB
jre11-openjdk-headless: 159.8 MiB
gcc-libs: 137.8 MiB
llvm-libs: 120.5 MiB
erlang-nox: 105.8 MiB
===========================================
```

### I'm receiving errors from Podman or Podman Compose

If you see errors similar to this:

`ERRO[0000] running `/usr/sbin/newuidmap 25137 0 1000 1 1 75537 65535`: newuidmap: write to uid_map failed: Operation not permitted`

Then run this in the terminal:

    $ __webdevbox_podman_config

The initial welcome script already runs this, but for some reason the error comes back until we run this again.

Happy Hacking!

### Links

* [Distrobox](https://github.com/89luca89/distrobox)
* [LunarVim](https://github.com/LunarVim/LunarVim)
* [Learn Vim](https://github.com/iggredible/Learn-Vim)
* [Chezmoi](https://www.chezmoi.io/user-guide/command-overview/)
* [RedHat: How to use Podman inside of container](https://www.redhat.com/sysadmin/podman-inside-container)
* [Rootless Podman](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)
* [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
* [ChatGPT in Vim](https://github.com/jackMort/ChatGPT.nvim)
* [Writing Your Tmux Config: a Detailed Guide](https://thevaluable.dev/tmux-config-mouseless/)
* [Useful Tmux Configuration Examples](https://dev.to/iggredible/useful-tmux-configuration-examples-k3g)
* [Awesome Tmux Plugins](https://github.com/rothgar/awesome-tmux#plugins)
* [JAIME'S GUIDE TO TMUX: THE MOST AWESOME TOOL YOU DIDN'T KNOW YOU NEEDED](https://www.barbarianmeetscoding.com/blog/jaimes-guide-to-tmux-the-most-awesome-tool-you-didnt-know-you-needed)
* [Atuin: A Powerful Alternative for Shell History](https://trendoceans.com/atuin-linux/)

Copyright (C) Fabio Akita - 2023
[MIT LICENSED](LICENSE)
