## Distrobox Web Dev Env

This is an Arch/Manjaro based Docker image that comes pre-installed with
everything I think a web developer would need in the 2020s. Every language, every tool, every helper.

Take a look in the [Dockerfile](Dockerfile) to see all packages, but in summary:

* ZSH (of course) but with several plugins
* Chezmoi to sync your dotfiles
* LunarVim already configured to work with TMUX
* All major languages (Ruby, Nodejs, Python, PHP, Kotlin, etc)
* ASDF so you can install specific old language versions for your projects
* Podman by default, and every Devops tool (K8S, Skaffold, Helm, Terraform, etc)
* All the normal debug tools (lsof, strace, etc)

## Usage

First, install Podman in your OS (Docker works fine as well), for example, in Arch:

    $ sudo pacman -S podman

Now install Distrobox. I tried the "distrobox-git" package in AUR, but Distrobox is still in heavy development and I got an old bug that was already solved in main, so I recommend installing the "unstable" version manually:

    $ curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh -s -- --next

Finally, you can build the image:

    $ git clone https://github.com/akitaonrails/webdevbox.git
    $ cd webdevbox
    $ podman build . -t akitaonrails/webdevbox

Now, it's normal Distrobox usage. Let's create the box and enter:

    $ mkdir -p ~/.local/share/distrobox/webdevbox
    $ distrobox create -i akitaonrails/webdevbox \
      -n webdevbox-demo -I \
      -H ~/.local/share/distrobox/webdevbox \
      --volume /home/akitaonrails:/mnt/host
    $ distrobox enter webdevbox-demo


*IMPORTANT:* I don't like Distrobox's default behavior of mapping the internal home directory directly on top of your real home directory. I had accidents of running things in the box, forgetting about this just to realize I had screwed up my home files. Luckily I use BTRFS with scheduled snapshots so I could easily rollback. But it's an unnecessary risk.

Instead I prefer to map to a new directory and have a separated home per box. Then map my home as an external drive in "/mnt/host".

2 things to do inside the box:

    # sudo chown -R $UID:$GID ~/.local
    # sudo chown -R $UID:$GID ~/.config

This is possibly a Distrobox bug. It copies the `/etc/skel` files as I wanted but failed to change the ownership. So do it manually as shown above.

Then we can initialize [Chezmoi](https://www.chezmoi.io/). I'd recommend first forking my [dotfiles repository](https://github.com/akitaonrails/dotfiles), but let's use it as example:

    $ chezmoi init https://github.com/akitaonrails/dotfiles
    $ chezmoi update

It will prompt you for your specific information such as preferred Git email. I configured Tmux to have the key bind "Ctrl+Alt+n" to open a new pane directly to some documents folder to serve as a shortcut for times when you want to make quick notes or add reminders. I usually point to my Dropbox synced Obsidian directory, for example.

And that's it. You can start working! Things to highlight:

* Type `git la` to see the git aliases I configured
* Read the `.tmux.conf` file to see what features I added
* Read the `.config/lvim/config.lua` file to see what plugins I have added
* LunarVim and Tmux are integrated so "Ctrl-(arrows)" will move your cursor not only between LunarVim panes, but also across Tmux panes!
* The first time you start LunarVim it will take a while for Packer to install its plugins

Happy Hacking!

Copyright (C) Fabio Akita - 2023
[MIT LICENSED](LICENSE)
