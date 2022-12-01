#!/bin/bash
#Creating function for installing chrome and uninstalling if already installed

install_chrome(){
#if condition to check if the package setup file is already present, if yes then remove it
if [ -e google-chrome-stable_current_amd64.deb ]
        then
        rm google-chrome-stable_current_amd64.deb
fi
        #if condition for checking if chrome browser already installed, if yes then uninstalling it using redirection
if sudo dpkg -s google-chrome-stable >/usr/bin/google-chrome-stable
then
        echo "Chrome browser found"
        #creating variable to store that the version is latest or not
        remote_ver=$(apt search google-chrome-stable | grep -o installed)
        #condition will verify if the latest version is installed or not
                if [[ $remote_ver = "installed" ]]
                #if yes then skip the installation
                then
                        echo "Already Latest Version Installed"
                #if not then uninstall the old version and install the latest stable version
                else
                        echo -e "latest version not installed\n\nRemoving old version"
                        #removing the old version
                        dpkg -P google-chrome-stable
                        echo "Latest chrome browser installation"
                #fetching the latest stable chrome browser and installing the same using wget to download and dpkg -i to install
                wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                dpkg -i google-chrome-stable_current_amd64.deb
                fi
else
        #else statement if chrome is not already installed then install the latest version
        echo "Chrome not installed and now is being installed"

        #fetching and installing the latest stable chrome browser version usimng wget to download and dpkg -i to install
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        dpkg -i google-chrome-stable_current_amd64.deb
fi
#if else statement ends
}
        #second function to fetch chromedriver corresponding to the installed latest stable version of google chrome
install_chromedriver(){
#if condition to check ifchromedriver.zip file is already present, if yes then remove the same
if [ -e chromedriver.zip ]
        then
        rm chromedriver.zip
        rm chromedriver
fi

        #using wget -O to write the content of link to a variable named getdriver
getdriver=$(wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE)

        # using wget -O to write the downloaded content to a desired file
        wget -O chromedriver.zip 'http://chromedriver.storage.googleapis.com/'$getdriver'/chromedriver_linux64.zip'

        #unzipping the downloaded file
        unzip chromedriver.zip

        #giving executable permission to the unzipped file
        chmod +x chromedriver

}

#calling the function to install chrome
echo -e "\nInstalling Chrome\n"
install_chrome

#calling the function to install chromedriver corresponing to the installed stable chrome browser
echo -e "\nInstalling Chromedriver\n"
install_chromedriver
