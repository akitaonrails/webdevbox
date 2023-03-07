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
        sudo \
        terraform \
        tmux \
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
        kubectl-bin \
        kustomize-bin \
        openshift-client-bin \
        skaffold-bin \
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
    && asdf plugin-add perl \
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

RUN chown -R 1000:1000 /etc/skel/.local \
    && chown -R 1000:1000 /etc/skel/.config

RUN echo "source /opt/asdf-vm/asdf.sh" >> /etc/profile ;\
    sed 's/PATH=/PATH=$HOME\/.local\/bin/g' -i /etc/profile

RUN archlinux-java set java-8-openjdk

CMD ["/bin/zsh"]
