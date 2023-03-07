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
    $ distrobox create 
      -i akitaonrails/webdevbox \
      -n webdevbox-demo -I \
    $ distrobox enter webdevbox-demo

*WARNING:* Distrobox automatically maps its internal home directory directly on top of your real home. It will also automatically create a user with the same username,
so it should be very seamleass to transition between them. But be careful that whatever destructive command you run over your home files, will be
permanent. If you prefer not to expose your home directory directly, you can point the internal home to somewhere else, like this:

    $ distrobox create 
      -i akitaonrails/webdevbox \
      -n webdevbox-demo -I \
      -H ~/.local/share/distrobox/webdevbox \
      --volume /home/akitaonrails:/mnt/host

I prefer to map to a new directory and have a separated home per box. Then map my home as an external drive in "/mnt/host".

Then we can initialize [Chezmoi](https://www.chezmoi.io/). I'd recommend first forking my [dotfiles repository](https://github.com/akitaonrails/dotfiles), but let's use it as example:

    $ chezmoi init https://github.com/akitaonrails/dotfiles
    $ chezmoi update

It will prompt you for your specific information such as preferred Git email. I configured Tmux to have the key bind "Ctrl+Alt+n" to open a new pane directly to some documents folder to serve as a shortcut for times when you want to make quick notes or add reminders. I usually point to my Dropbox synced Obsidian directory, for example.

And if you want to run podman inside Distrobox (yes! you can run a new container inside another container, podman is already configured to run rootless inside), and if you chose
to map your home directory directly to your real home, then make sure to create the volume for the containers:

    $ mkdir -p $HOME/.local/share/containers/storage/

Whenere you `podman pull` inside the Box, the blobs will be stored there, so not to bloat the image

And that's it. You can start working!

## FAQ

### Did you configure Git Aliases?

Yes, type `git la` to have a list of all the built-in aliases

### How do I navigate in Tmux?

The navigation keybinding are diffent. The same Ctrl+[hjkl] are used to navigate between
both Tmux panels and LunarVim panels.

I also configured navigaton in copy mode to be like Vim (hjkl).

Do read [.tmux.conf](https://github.com/akitaonrails/dotfiles/blob/main/dot_tmux.conf.tmpl) from my dotfiles repo.

### Did you customize LunarVim?

LunarVim is mostly stock. I did add a few plugins such as GitHub CoPilot and ChatGPT.

Do read [config.lua](config.lua), and go to the bottom of the file to see what I changed.

### Why didn't you install virtualenv, nvm or rvm?

Because the box comes with the much superior [ASDF](https://asdf-vm.com/guide/getting-started.html).

### Why do you install the pacman language packages if you installed ASDF?

The best practice is to have the native packages in the OS do their job. Only configure
custom language versions from asdf per project. For example:

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

Happy Hacking!

Copyright (C) Fabio Akita - 2023
[MIT LICENSED](LICENSE)
