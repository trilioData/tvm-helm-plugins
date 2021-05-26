#!/usr/bin/env bash
cd "$HELM_PLUGIN_DIR" || exit
version="$(grep  "version" plugin.yaml | cut -d ' ' -f 2)"
echo "Installing tvm-upgrade ${version} ..."
# Find correct archive name
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)             os=linux;;
    Darwin*)            os=darwin;;
    *)                  os=windows;;
esac
archOut=$(uname -m)
case "${archOut}" in
    amd64*)             arch=amd64;;
    x86_64*)            arch=amd64;;
    arm64*)             arch=amd64;;
    arm*)               arch=arm;;
    *)                  arch=386;;
esac
echo "OS/Arch : ${os}/${arch}"
url="https://github.com/trilioData/tvm-helm-plugins/releases/download/${version}/tvm-upgrade_${version}_${os}_${arch}.tar.gz?raw=true"
filename=$(echo "${url}" | sed -e "s/^.*\///g" | awk -F "?" '{print $1}')
echo "Filename : ${filename} "
  # Download archive
  if type "curl" >/dev/null 2>&1; then
      curl -sSL -o "$filename" "$url"
  elif type "wget" >/dev/null 2>&1; then
      wget -q -O "$filename" "$url"
  else
      echo "Need curl or wget"
      exit 1
  fi
echo "Downloaded Binary tar"
# Install bin
rm -rf bin && mkdir bin && tar xvf "$filename" -C bin > /dev/null && rm -f "$filename"
PATH=$PATH:$(pwd)/bin
tvm-upgrade -h
if [ "${os}" = "windows" ]; then
    echo "Press enter to continue ...."
fi