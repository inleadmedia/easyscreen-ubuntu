#!/bin/bash
auth_token="$1";
destination="$2";
lms_domain="$3";
branch=$4;
TMID="$5";

if [ "$auth_token" == "" ] || [ "$destination" == "" ] || [ "$lms_domain" == "" ]; then
  echo "install java jdk and jre, rfid scanner shared libraries, nodejs modules and setup config file.";
  echo "usage: install.sh <auth-token> <destination> <lms-domain> <application-branch> <TMID>";
  echo "example:";
  echo "  auth-token: token of github https client. Required."
  echo "  destination: absolute destination path for application. Required."
  echo "  lms-domain: https://stg.lms.inlead.ws. Required.";
  echo "  application-branch: develop. By default used 'master' branch.";
  echo "  TMID: TMID for app settings. If not provided will taken from teamviewer info but in this case teamviewer util should be installed."
  echo "  "
  exit 1;
fi

sudo apt-get update -qq

# Check and install required utilites.

command -v sed > /dev/null || {
  sudo apt-get -qq install sed;
}

command -v java > /dev/null || {
  sudo apt-get -qq install default-jdk;
}

command -v javac > /dev/null || {
  sudo apt-get -qq install default-jre;
}

command -v node > /dev/null || {
  . ~/.nvm/nvm.sh
  . ~/.profile
  . ~/.bashrc

  nvm install 8 && nvm use 8;
}

command -v git > /dev/null || {
  sudo apt-get -qq install git;
}

command -v grep > /dev/null || {
  sudo apt-get -qq install grep;
}

command -v evtest > /dev/null || {
  sudo apt-get -qq install evtest;
}

command -v xinput > /dev/null || {
  sudo apt-get -qq install xinput;
}

# Get teamviewer id.
if [ "$TMID" == "" ];  then
  command -v teamviewer > /dev/null || { echo "Teamviewer should be installed."; exit 1; }
  
  TMID="$(teamviewer info | grep -oE 'TeamViewer ID.+[0-9]+' | sed -r 's/[^0-9]*//' | sed 's/0m  //')"
fi


if [ "$branch" == "" ];  then 
  branch="develop"
fi

# Clone main app and checkout into selected branch.
git clone "https://$auth_token@github.com/inleadmedia/es-linux-apps.git" "$destination" && cd "$destination" && git checkout "$branch" && 

# Install nodejs deps.
npm install &&

# Install rfid libs
if [ ! -d "/usr/lib" ]; then
  sudo mkdir /usr/lib;
fi

cd ./node_modules/es-linux-rfidscanner/java-app/drivers;
sudo bash ./install-libs.sh /usr/lib;
cd ../../../../;

# Setup TM ID

sed -i -E "s/user: \"[0-9]+\"/user: \"$TMID\"/" "$destination/./config.js";

# Setup lms domain
sed -i -E "s|domain: \".+\"|domain: \"$lms_domain\"|" "$destination/./config.js";

# Remove unnecessary files
rm -rf "$destination/./.git"; 
rm "$destination/./install-nvm.sh";
rm "$destination/./install-app.sh";
rm "$destination/./package.json";
rm "$destination/./package-lock.json";
rm "$destination/./.gitignore";

# Copy installed node for using with sudo
n=$(which node);
n=${n%/bin/node};
chmod -R 755 $n/bin/*;
sudo cp -r $n/{bin,lib,share} /usr/local;

echo "Use \"sudo node $destination/./index.js\" for run application";
exit 0;

