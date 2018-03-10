if declare -f -F nvm >/dev/null
then
  echo "nvm is installed"
else
  echo "nvm is NOT installed"
  # curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
  # source ~/.bash_profile
fi

if declare -f -F rbenv >/dev/null
then
  echo "rbenv is installed"
else
  echo "rbenv is NOT installed"
fi
