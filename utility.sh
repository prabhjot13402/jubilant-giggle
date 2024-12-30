#!/bin/bash

node_version=14
ubuntu_packages=(apt-utils subversion wget unzip software-properties-common gnupg2 curl apt-transport-https vim nano)
additional_packages=(postgresql-client libapache-pom-java libapache2-mod-security2 libxml2-utils fop python3-psycopg2 ruby swish-e xsltproc)

# Getting the Operating System version codename.
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  if [[ $ID = ubuntu ]]; then
    OS_CODENAME=$VERSION_CODENAME
    # echo "Running Ubuntu $OS_CODENAME"
  else
    echo "Not running an Ubuntu distribution. ID=$ID, VERSION=$VERSION_CODENAME"
  fi
else
  echo "Not running a distribution with /etc/os-release available"
fi

# echo $OS_NAME
# echo $OS_CODENAME

log_i() {
    printf "\033[0;32m [INFO]  --- %s \033[0m\n" "${@}"
}
log_w() {
    printf "\033[0;35m [WARN] --- %s \033[0m\n" "${@}"
}
log_e() {
    printf "\033[0;31m [ERROR]  --- %s \033[0m\n" "${@}"
}

# Function to install packages
install_packages() { 
    apt-get -y update --fix-missing &> /dev/null

    for index in ${!ubuntu_packages[*]}; do
        log_i "Installing utility ${ubuntu_packages[$index]}"
        apt-get install -y ${ubuntu_packages[$index]} &> /dev/null
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${ubuntu_packages[$index]} | grep "install ok installed")
        if [ -z "$PKG_OK" ]; then
            log_e "${ubuntu_packages[$index]} utility failed to install. Exiting..."
            exit 1
        else
            log_i "${ubuntu_packages[$index]} utility installed successfully"
        fi
    done
}

# Function to install Node.js
install_nodejs() {
    log_i "Configuring installation for Node.js..."
    mkdir -p /etc/apt/keyrings &> /dev/null
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &> /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${node_version}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list &> /dev/null
    log_i "Installing Node.js version ${node_version}."
    apt-get update -y &> /dev/null
    apt-get install -y nodejs npm &> /dev/null
    node -v &> /dev/null
    if [ $? -eq 0 ]; then
        log_i "Node.js installed successfully!"
    else
        log_e "Failed to install Node.js."
        exit 1
    fi
}

# Function to install Yarn
install_yarn() {
    log_i "Installing Yarn"
    npm install --global yarn &> /dev/null
    yarn -v &> /dev/null
    if [ $? -eq 0 ]; then
        log_i "Yarn installed successfully!"
    else
        log_e "Failed to install Yarn."
        exit 1
    fi
}

# Function to install Java
install_java() {
    log_i "Installing Java..."
    mkdir -p /usr/share/man/man1
    apt-get install -y openjdk-8-jre-headless &> /dev/null
    apt-get install -y ca-certificates-java &> /dev/null
    apt-get install -y default-jre-headless &> /dev/null
    java -version &> /dev/null
    if [ $? -eq 0 ]; then
        log_i "Java installed successfully!"
    else
        log_e "Failed to install Java."
        exit 1
    fi
    mkdir -p /usr/share/man/man7
}

# Function to install PostgreSQL
install_postgres() {
    log_i "Installing PostgreSQL..."
    wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &> /dev/null
    add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -sc`-pgdg main" &> /dev/null
    apt-get update &> /dev/null
    apt-get install -y postgresql-client-12 &> /dev/null
    psql --version &> /dev/null
    if [ $? -eq 0 ]; then
        log_i "PostgreSQL installed successfully!"
    else
        log_e "Failed to install PostgreSQL."
        exit 1
    fi
    apt-get update &> /dev/null
    apt-get install -y --no-install-recommends tzdata &> /dev/null
}

# Function to install Apache
install_apache() {
    log_i "Installing Apache..."
    apt-get update -y &> /dev/null
    echo "deb http://ppa.launchpad.net/ondrej/apache2/ubuntu/ $OS_CODENAME main" >> /etc/apt/sources.list.d/apache_ondrej.list
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C  &> /dev/null
    apt-get update -y &> /dev/null
    apt-get install -y apache2 &> /dev/null
    apache2 -v &> /dev/null
    if [ $? -eq 0 ]; then
        log_i "Apache installed successfully!"
    else
        log_e "Failed to install Apache."
        exit 1
    fi
}

# Function to install additional packages
install_additional_packages() {
    apt-get -y update --fix-missing &> /dev/null

    for index in ${!additional_packages[*]}; do
        log_i "Installing utility ${additional_packages[$index]}"
        apt-get install -y ${additional_packages[$index]} &> /dev/null
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${additional_packages[$index]} | grep "install ok installed")
        if [ -z "$PKG_OK" ]; then
            log_e "${additional_packages[$index]} utility failed to install. Exiting..."
            exit 1
        else
            log_i "${additional_packages[$index]} utility installed successfully"
        fi
    done
}

# Main execution starts here
install_packages
install_nodejs
install_yarn
install_postgres
install_apache
install_additional_packages
