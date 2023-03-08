source $HOME/.config/zsh/webdevbox.zsh

if [ -f /var/tmp/first-time.lock ]; then
  sudo chown -R $UID:$GID $HOME/.config
  sudo chown -R $UID:$GID $HOME/.local
  __webdevbox_podman_config

  echo "Welcome to webDevBox"
  __webdevbox_welcome
  __webdevbox_instructions

  sudo rm /var/tmp/first-time.lock # remove first time flag
  mv $HOME/.zshrc /tmp # expect chezmoi to create a new one
  cd $HOME
fi
