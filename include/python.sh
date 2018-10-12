#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack
#       https://github.com/tekintian/oneinstack_mphp

Install_Python() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ "${CentOS_ver}" == '7' ]; then
    [ ! -e /etc/yum.repos.d/epel.repo ] && cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
  elif [ "${CentOS_ver}" == '6' ]; then
    [ ! -e /etc/yum.repos.d/epel.repo ] && cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
  fi

  if [ "${PM}" == 'yum' ]; then
    pkgList="gcc dialog augeas-libs openssl openssl-devel libffi-devel redhat-rpm-config ca-certificates"
    for Package in ${pkgList}; do
      yum -y install ${Package}
    done
  elif [ "${PM}" == 'apt' ]; then
    pkgList="gcc dialog libaugeas0 augeas-lenses libssl-dev libffi-dev ca-certificates"
    for Package in ${pkgList}; do
      apt-get -y install $Package
    done
  fi

  # Install Python3
  if [ ! -e "${python_install_dir}/bin/python" -a ! -e "${python_install_dir}/bin/python3" ] ;then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/Python-${python_ver}.tgz && Download_src
    tar xzf Python-${python_ver}.tgz
    pushd Python-${python_ver}
    ./configure --prefix=${python_install_dir}
    make && make install
    [ ! -e "${python_install_dir}/bin/python" -a -e "${python_install_dir}/bin/python3" ] && ln -s ${python_install_dir}/bin/python{3,}
    [ ! -e "${python_install_dir}/bin/pip" -a -e "${python_install_dir}/bin/pip3" ] && ln -s ${python_install_dir}/bin/pip{3,}
    popd
    rm -rf Python-${python_ver}
  fi

  if [ ! -e "/root/.pip/pip.conf" ] ;then
    # get the IP information
    PUBLIC_IPADDR=$(../include/get_public_ipaddr.py)
    IPADDR_COUNTRY=$(../include/get_ipaddr_state.py $PUBLIC_IPADDR)
    if [ "$IPADDR_COUNTRY"x == "CN"x ]; then
      [ ! -d "/root/.pip" ] && mkdir /root/.pip
      echo -e "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple" > /root/.pip/pip.conf
    fi
  fi
  popd
}
