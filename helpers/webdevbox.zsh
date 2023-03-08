__webdevbox_welcome() {
   echo '    __  _  __ ____\_ |__    __| _/_______  _\_ |__   _______  ___'
   echo '    \ \/ \/ // __ \| __ \  / __ |/ __ \  \/ /| __ \ /  _ \  \/  /'
   echo '     \     /\  ___/| \_\ \/ /_/ \  ___/\   / | \_\ (  <_> >    < '
   echo '      \/\_/  \___  >___  /\____ |\___  >\_/  |___  /\____/__/\_ \'
   echo '                 \/    \/      \/    \/          \/            \/'
   echo '61 6B 69 74 61 6F 6E 72 61 69 6C 73 40 43 6F 64 65 4D 69 6E 65 72 34 32'
 }

__webdevbox_instructions() {
  echo ""
  echo "Run 'chezmoi init <git-repo-url>' to initialize your dotfiles."
  echo "Atuin is enabled, register with atuin register; atuin import auto; atuin sync. Ctrl+r opens the search."
  echo "If you're using an isolated home folder, don't forget to symlink your ~/.ssh."
  echo "Open Tmux and install the plugins with Ctrl+B and Shift+I, then Ctrl+b and r to reload."
  echo ""
}

__webdevbox_podman_config() {
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
}
