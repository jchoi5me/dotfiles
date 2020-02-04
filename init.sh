#!/usr/bin/env bash
#assumes that xcode-select --install was run

printf '\nManually Copying...\n' >&2
find backups/Users/* -mindepth 1 -maxdepth 1 |
  while read FILE; do
   echo cp -rv "$FILE" ~/  # in the future make a hard link?
  done

# Homebrew
printf '\nChecking HomeBrew...\n' >&2
if ! which brew; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew bundle install --file='manual-backups/Brewfile-bare'

printf '\nChecking VimPlug...\n' >&2
# Vim Plug
if ! [[ -f "$HOME/.vim/autoload/plug.vim" ]]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

for _ in 1 2; do
  vim +PlugInstall +qall
done

printf '\nChecking Vundle...\n' >&2
# Vundle
if ! [[ -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
  git clone 'https://github.com/VundleVim/Vundle.vim.git' ~/.vim/bundle/Vundle.vim
fi

for _ in 1 2; do
  vim +PluginInstall +qall
done

printf '\nChecking Cargo...\n' >&2
if ! which cargo; then
  rustup-init --no-modify-path -y
fi

while read PACKAGE; do
  cargo install "$PACKAGE"
done < 'manual-backups/cargo_packages.txt'

parallel 'apm install {}' < 'manual-backups/atom-packages.txt'

