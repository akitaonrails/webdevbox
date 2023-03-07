if [ -f /var/tmp/first-time.lock ]; then
  sudo chown -R $UID:$GID $HOME/.config
  sudo chown -R $UID:$GID $HOME/.local

  # not sure why, but I have to run this lower setting first
  sudo su -c "echo podman:10000:10000 > /etc/subuid"
  sudo su -c "echo podman:10000:10000 > /etc/subgid"
  sudo sh -c "echo $USER:20001:10000 >> /etc/subuid"
  sudo sh -c "echo $USER:20001:10000 >> /etc/subgid"
  podman info > /dev/null

  # only now I can increate it
  sudo su -c "echo podman:10000:65535 > /etc/subuid"
  sudo su -c "echo podman:10000:65535 > /etc/subgid"
  sudo sh -c "echo $USER:75537:65535 >> /etc/subuid"
  sudo sh -c "echo $USER:75537:65535 >> /etc/subgid"

  echo "Run 'chezmoi init <git-repo-url>' to initialize your dotfiles"
  sudo rm /var/tmp/first-time.lock # remove first time flag
  cd $HOME
  rm $HOME/.zshrc # expect chezmoi to create a new one
fi
