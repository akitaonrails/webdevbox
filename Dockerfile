FROM docker.io/library/archlinux as update-mirrors
ARG PACMAN_PARALLELDOWNLOADS=5
RUN pacman-key --init \
    && pacman-key --populate archlinux \
    && sed 's/ParallelDownloads = \d+/ParallelDownloads = ${PACMAN_PARALLELDOWNLOADS}/g' -i /etc/pacman.conf \
    && sed 's/NoProgressBar/#NoProgressBar/g' -i /etc/pacman.conf

# update mirrorlist
ADD https://raw.githubusercontent.com/greyltc/docker-archlinux/master/get-new-mirrors.sh /usr/bin/get-new-mirrors
RUN chmod +x /usr/bin/get-new-mirrors
RUN get-new-mirrors

RUN pacman -Syyu --noconfirm \
        aardvark-dns \
        apparmor \
        base-devel \
        bat \
        chromium \
        chezmoi \
        cifs-utils \
        curl \
        elixir \
        exa \
        fd \
        ffmpeg \
        fish \
        fzf \
        fuse-overlayfs \
        git \
        git-lfs \
        go \
        helm \
        htop \
        imagemagick \
        lsof \
        jdk11-openjdk \
        jdk8-openjdk \
        mariadb-clients \
        memcached \
        neovim \
        nodejs \
        node-gyp \
        npm \
        opencv \
        openssh \
        pgcli \
        php \
        podman \
        podman-compose \
        podman-docker \
        podman-dnsname \
        postgresql-libs \
        python-pip \
        python-numpy \
        python-pandas \
        python-pygments \
        redis \
        ripgrep \
        ruby \
        rust \
        starship \
        strace \
        sqlite3 \
        sudo \
        terraform \
        tmux \
        tmuxp \
        unzip \
        wget \
        wl-clipboard \
        xsel \
        xclip \
        yarn \
        zsh-autosuggestions \
        zsh-completions \
        zsh-history-substring-search \
        zsh-syntax-highlighting \
        zsh-theme-powerlevel10k \
    ; pacman -Rns $(pacman -Qtdq) \
    ; pacman -Sc --noconfirm

RUN archlinux-java set java-8-openjdk

# configure podman for rootless
RUN useradd podman \
    ; echo podman:10000:10000 > /etc/subuid \
    ; echo podman:10000:10000 > /etc/subgid

VOLUME /var/lib/containers
VOLUME /home/podman/.local/share/containers

ADD containers.conf /etc/containers/containers.conf
ADD podman-containers.conf /home/podman/.config/containers/containers.conf

RUN chown podman:podman -R /home/podman

# chmod containers.conf and adjust storage.conf to enable Fuse storage.
RUN chmod 644 /etc/containers/containers.conf \
    ; sed -i -e 's|^#mount_program|mount_program|g' \
    -e '/additionalimage.*/a "/var/lib/shared",' \
    -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
    /etc/containers/storage.conf

RUN mkdir -p /var/lib/shared/overlay-images \
    /var/lib/shared/overlay-layers \
    /var/lib/shared/vfs-images \
    /var/lib/shared/vfs-layers \
    ; touch /var/lib/shared/overlay-images/images.lock \
    ; touch /var/lib/shared/overlay-layers/layers.lock \
    ; touch /var/lib/shared/vfs-images/images.lock \
    ; touch /var/lib/shared/vfs-layers/layers.lock

ENV _CONTAINERS_USERNS_CONFIGURED=""

# Install Yay and continue with it
FROM update-mirrors as build-helper-img
ARG AUR_USER=builduser
ARG HELPER=yay
ARG LUNARVIM_VERSION=1.2
ARG NEOVIM_VERSION=0.8

ADD add-aur.sh /root
RUN bash /root/add-aur.sh ${AUR_USER} ${HELPER}

RUN aur-install \
        asdf-vm \
        aws-cli \
        azure-cli \
        google-cloud-sdk \
        heroku-cli \
        insomnia-bin \
        kubectl-bin \
        kustomize-bin \
        openshift-client-bin \
        postman-bin \
        skaffold-bin \
        terragrunt \
        wrk \
        zsh-git-prompt \
        zsh-vi-mode \
    ; pacman -Rns $(pacman -Qtdq) \
    ; pacman -Sc --noconfirm

RUN source /opt/asdf-vm/asdf.sh \
    && asdf plugin-add crystal \
    && asdf plugin-add dotnet-core \
    && asdf plugin-add elixir \
    && asdf plugin-add erlang \
    && asdf plugin-add golang \
    && asdf plugin-add haskell \
    && asdf plugin-add java \
    && asdf plugin-add julia \
    && asdf plugin-add kotlin \
    && asdf plugin-add lua \
    && asdf plugin-add nim \
    && asdf plugin-add nodejs \
    && asdf plugin-add php \
    && asdf plugin-add python \
    && asdf plugin-add ruby \
    && asdf plugin-add rust \
    && asdf plugin-add scala \
    && asdf plugin-add zig 

RUN LV_BRANCH="release-${LUNARVIM_VERSION}/neovim-${NEOVIM_VERSION}" \
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh) -y \
    && mkdir -p /etc/skel/.local/share \
    && mkdir -p /etc/skel/.local/bin \
    && mkdir -p /etc/skel/.config/lvim \
    && mv /root/.local/share/lunarvim /etc/skel/.local/share/lunarvim \
    && mv /root/.local/bin/lvim /etc/skel/.local/bin/lvim \
    && sed 's/\/root/$HOME/g' -i /etc/skel/.local/bin/lvim

COPY config.lua /etc/skel/.config/lvim

# I don't know if this is necessary, seems like Distrobox has a bug in 
# distrobox-init where it manually copies from /etc/skel but fails to chown
# but setting it here doesn't appear to solve it either
RUN chown -R 1000:1000 /etc/skel/.local \
    && chown -R 1000:1000 /etc/skel/.config

RUN echo "source /opt/asdf-vm/asdf.sh" >> /etc/profile ;\
    sed 's/PATH=/PATH=$HOME\/.local\/bin/g' -i /etc/profile

CMD ["/bin/zsh"]
