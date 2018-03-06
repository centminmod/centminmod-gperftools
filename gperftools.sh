#!/bin/bash
################################################
# Google gperftools for Centmin Mod on CentOS
# https://github.com/gperftools/gperftools
################################################
VER='0.1'
DT=$(date +"%d%m%y-%H%M%S")
DIR_TMP='/svr-setup'

# RPM related
BUILTRPM='y'
DISTTAG='el7'
RPMSAVE_PATH="$DIR_TMP"
# whether to test install the RPMs build
# or just build RPMs without installing
YUMINSTALL='n'

GPERFTOOLS_SOURCEINSTALL='y'
GPERFTOOLS_TMALLOCLARGEPAGES='y'  # set larger page size for tcmalloc --with-tcmalloc-pagesize=32
LIBUNWIND_VERSION='1.2.1'           # note google perftool specifically requies v0.99 and no other
GPERFTOOLS_VERSION='2.6.3'        # Use this version of google-perftools

LIBUNWIND_LINKFILE="libunwind-${LIBUNWIND_VERSION}.tar.gz"
LIBUNWIND_LINKDIR="libunwind-${LIBUNWIND_VERSION}"
LIBUNWIND_LINK="http://download.savannah.gnu.org/releases/libunwind/${LIBUNWIND_LINKFILE}"

GPERFTOOL_LINKFILE="gperftools-${GPERFTOOLS_VERSION}.tar.gz"
GPERFTOOL_LINKDIR="gperftools-${GPERFTOOLS_VERSION}"
GPERFTOOL_LINK="https://github.com/gperftools/gperftools/releases/download/gperftools-${GPERFTOOLS_VERSION}/${GPERFTOOL_LINKFILE}"

SCRIPT_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
################################################
# Setup Colours
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'

boldblack='\E[1;30;40m'
boldred='\E[1;31;40m'
boldgreen='\E[1;32;40m'
boldyellow='\E[1;33;40m'
boldblue='\E[1;34;40m'
boldmagenta='\E[1;35;40m'
boldcyan='\E[1;36;40m'
boldwhite='\E[1;37;40m'

Reset="tput sgr0"      #  Reset text attributes to normal
                       #+ without clearing screen.

cecho ()                     # Coloured-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
message=$1
color=$2
echo -e "$color$message" ; $Reset
return
}

################################################
CENTOSVER=$(awk '{ print $3 }' /etc/redhat-release)

if [[ "$GPERFTOOLS_TMALLOCLARGEPAGES" = [yY] ]]; then
    TCMALLOC_PAGESIZE='32'
else
    TCMALLOC_PAGESIZE='8'
fi

if [ "$CENTOSVER" == 'release' ]; then
    CENTOSVER=$(awk '{ print $4 }' /etc/redhat-release | cut -d . -f1,2)
    if [[ "$(cat /etc/redhat-release | awk '{ print $4 }' | cut -d . -f1)" = '7' ]]; then
        CENTOS_SEVEN='7'
    fi
fi

if [[ "$(cat /etc/redhat-release | awk '{ print $3 }' | cut -d . -f1)" = '6' ]]; then
    CENTOS_SIX='6'
fi

# Check for Redhat Enterprise Linux 7.x
if [ "$CENTOSVER" == 'Enterprise' ]; then
    CENTOSVER=$(awk '{ print $7 }' /etc/redhat-release)
    if [[ "$(awk '{ print $1,$2 }' /etc/redhat-release)" = 'Red Hat' && "$(awk '{ print $7 }' /etc/redhat-release | cut -d . -f1)" = '7' ]]; then
        CENTOS_SEVEN='7'
        REDHAT_SEVEN='y'
    fi
fi

if [[ -f /etc/system-release && "$(awk '{print $1,$2,$3}' /etc/system-release)" = 'Amazon Linux AMI' ]]; then
    CENTOS_SIX='6'
fi

if [ ! -d "$DIR_TMP" ]; then
    mkdir -p $DIR_TMP
fi

if [ -f /proc/user_beancounters ]; then
    # CPUS='1'
    # MAKETHREADS=" -j$CPUS"
    # speed up make
    CPUS=$(grep -c "processor" /proc/cpuinfo)
    if [[ "$CPUS" -gt '8' ]]; then
        CPUS=$(echo $(($CPUS+2)))
    else
        CPUS=$(echo $(($CPUS+1)))
    fi
    MAKETHREADS=" -j$CPUS"
else
    # speed up make
    CPUS=$(grep -c "processor" /proc/cpuinfo)
    if [[ "$CPUS" -gt '8' ]]; then
        CPUS=$(echo $(($CPUS+4)))
    elif [[ "$CPUS" -eq '8' ]]; then
        CPUS=$(echo $(($CPUS+1)))
    else
        CPUS=$(echo $(($CPUS+1)))
    fi
    MAKETHREADS=" -j$CPUS"
fi

die() {
    echo "error: $@" >&2
    exit 1
}

tidyup() {
    # logs older than 5 days will be gzip compressed to save space 
    if [ -d /root/centminlogs ]; then
        # find /root/centminlogs -type f -mtime +3 \( -name 'gperftools-install_*.log"' -o -name 'gperftools-libunwind*.log' \) -exec ls -lah {} \;
        find /root/centminlogs -type f -mtime +3 \( -name 'gperftools-install_*.log"' -o -name 'gperftools-libunwind*.log' \) -exec gzip -9 {} \;
    fi
}

scl_install() {
    if [[ "$(gcc --version | head -n1 | awk '{print $3}' | cut -d . -f1,2 | sed "s|\.|0|")" -gt '407' ]]; then
        echo
        echo "install centos-release-scl for newer gcc and g++ versions"
        if [[ -z "$(rpm -qa | grep rpmforge)" ]]; then
            if [[ "$(rpm -ql centos-release-scl >/dev/null 2>&1; echo $?)" -ne '0' ]]; then
                time yum -y -q install centos-release-scl
            fi
        else
            if [[ "$(rpm -ql centos-release-scl >/dev/null 2>&1; echo $?)" -ne '0' ]]; then
                time yum -y -q install centos-release-scl --disablerepo=rpmforge
            fi
        fi
    fi
    if [[ -z "$(rpm -qa | grep rpmforge)" ]]; then
        if [[ "$(rpm -ql devtoolset-7-gcc >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-gcc-c++ >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-binutils >/dev/null 2>&1; echo  $?)" -ne '0' ]]; then
            time yum -y -q install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils
        fi
    else
        if [[ "$(rpm -ql devtoolset-7-gcc >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-gcc-c++ >/dev/null 2>&1; echo $?)" -ne '0' ]] || [[ "$(rpm -ql devtoolset-7-binutils >/dev/null 2>&1; echo  $?)" -ne '0' ]]; then
            time yum -y -q install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils --disablerepo=rpmforge
        fi
    fi
    if [[ "$CLANG_FOUR" = [yY] && ! -f /opt/rh/llvm-toolset-7/root/usr/bin/clang ]]; then
        time yum -y install devtoolset-7-runtime llvm-toolset-7-runtime devtoolset-7-libstdc++-devel llvm-toolset-7-clang llvm-toolset-7-llvm-libs llvm-toolset-7-llvm-static llvm-toolset-7-compiler-rt llvm-toolset-7-libomp llvm-toolset-7-clang-libs
    fi
    echo
}

fpm_install() {
    if [[ "$BUILTRPM" = [Yy] ]]; then
        if [ ! -f /usr/local/bin/fpm ]; then
        echo "*************************************************"
        cecho "Install FPM Start..." $boldgreen
        echo "*************************************************"
        echo
        
            fpmpkgs='ruby-devel gcc make rpm-build rubygems'
            for i in ${fpmpkgs[@]}; do 
                echo $i; 
                if [[ "$(rpm --quiet -ql $i; echo $?)" -ne '0' ]]; then
                    yum -y install $i
                fi
            done
            gem install --no-ri --no-rdoc fpm
            mkdir -p /home/fpmtmp

        echo "*************************************************"
        cecho "Install FPM Completed" $boldgreen
        echo "*************************************************"
        echo
        fi
    fi
}

download_files() {
    cd "$DIR_TMP"
    wget -cnv $LIBUNWIND_LINK
    wget -cnv $GPERFTOOL_LINK
    tar xzf "${LIBUNWIND_LINKFILE}"
    tar xzf "${GPERFTOOL_LINKFILE}"
}

install_libunwind() {
        LIBUNWIND_RPMINSTALLDIR="/home/fpmtmp/fpm-libunwind-tmpinstall"
        cd "${DIR_TMP}"
        rm -rf "${LIBUNWIND_RPMINSTALLDIR}"
        mkdir -p "${LIBUNWIND_RPMINSTALLDIR}"
        cd "${LIBUNWIND_LINKDIR}"
        ./configure
        make$MAKETHREADS
        if [[ "$BUILTRPM" = [Yy] ]]; then
            make install DESTDIR="$LIBUNWIND_RPMINSTALLDIR"
        else
            time make install
        fi

        if [ -f /usr/bin/xz ]; then
            FPMCOMPRESS_OPT='--rpm-compression xz'
        else
            FPMCOMPRESS_OPT='--rpm-compression gzip'
        fi

        echo -e "* $(date +"%a %b %d %Y") George Liu <centminmod.com> ${LIBUNWIND_VERSION}\n - libunwind ${LIBUNWIND_VERSION} for centminmod.com LEMP stack installs" > "libunwind-${LIBUNWIND_VERSION}-changelog"

        echo "fpm -f -s dir -t rpm -n cmm-libunwind -v ${LIBUNWIND_VERSION} $FPMCOMPRESS_OPT --rpm-changelog \"libunwind-${LIBUNWIND_VERSION}-changelog\" --rpm-summary \"libunwind-${LIBUNWIND_VERSION} for centminmod.com LEMP stack installs\" --rpm-dist ${DISTTAG}  -m \"<centminmod.com>\" --description \"libunwind-${LIBUNWIND_VERSION} for centminmod.com LEMP stacks\" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $LIBUNWIND_RPMINSTALLDIR" | tee -a "${SCRIPT_DIR}/libunwind-${LIBUNWIND_VERSION}-fpm-cmd"
        time fpm -f -s dir -t rpm -n cmm-libunwind -v ${LIBUNWIND_VERSION} $FPMCOMPRESS_OPT --rpm-changelog "libunwind-${LIBUNWIND_VERSION}-changelog" --rpm-summary "libunwind-${LIBUNWIND_VERSION} for centminmod.com LEMP stack installs" --rpm-dist ${DISTTAG}  -m "<centminmod.com>" --description "libunwind-${LIBUNWIND_VERSION} for centminmod.com LEMP stacks" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $LIBUNWIND_RPMINSTALLDIR

        # check provides and requires
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --provides \"${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --provides "${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo
        
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --requires \"${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --requires "${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo

        LINUNWIND_RPMPATH="${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm"
        ls -lah "$LINUNWIND_RPMPATH"
        if [[ "$YUMINSTALL" = [yY] ]]; then
            echo
            echo "yum -y localinstall ${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm"
            yum -y localinstall ${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm
        fi
    if [[ "$YUMINSTALL" = [yY] ]]; then
        echo "yum -y localinstall "${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm""
        yum -y localinstall "${DIR_TMP}/cmm-libunwind-${LIBUNWIND_VERSION}-1.${DISTTAG}.x86_64.rpm"
    else
        echo
    fi
}

install_gperftools() {
        GPERFTOOLS_RPMINSTALLDIR="/home/fpmtmp/fpm-gperftools-tmpinstall"
        cd "$DIR_TMP"
        cd "${GPERFTOOL_LINKDIR}"
        make distclean
        if [[ "$(uname -m)" = 'x86_64' ]]; then
            ./configure --with-tcmalloc-pagesize=$TCMALLOC_PAGESIZE
        else
            ./configure --enable-frame-pointers --with-tcmalloc-pagesize=$TCMALLOC_PAGESIZE
        fi
        make$MAKETHREADS
        if [[ "$BUILTRPM" = [Yy] ]]; then
            make install DESTDIR="$GPERFTOOLS_RPMINSTALLDIR"
        else
            time make install
        fi
        if [ ! -f /etc/ld.so.conf.d/wget.conf ]; then
            echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
            /sbin/ldconfig
        fi

        if [ -f /usr/bin/xz ]; then
            FPMCOMPRESS_OPT='--rpm-compression xz'
        else
            FPMCOMPRESS_OPT='--rpm-compression gzip'
        fi

        echo -e "* $(date +"%a %b %d %Y") George Liu <centminmod.com> ${LIBUNWIND_VERSION}\n - gperftools ${GPERFTOOLS_VERSION} for centminmod.com LEMP stack installs" > "gperftools-${GPERFTOOLS_VERSION}-changelog"

        echo "fpm -f -s dir -t rpm -n cmm-gperftools -v ${GPERFTOOLS_VERSION} $FPMCOMPRESS_OPT --rpm-changelog \"gperftools-${GPERFTOOLS_VERSION}-changelog\" --rpm-summary \"gperftools-${GPERFTOOLS_VERSION} for centminmod.com LEMP stack installs\" --rpm-dist ${DISTTAG}  -m \"<centminmod.com>\" --description \"gperftools-${GPERFTOOLS_VERSION} for centminmod.com LEMP stacks\" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $GPERFTOOLS_RPMINSTALLDIR" | tee -a "${SCRIPT_DIR}/gperftools-${GPERFTOOLS_VERSION}-fpm-cmd"
        time fpm -f -s dir -t rpm -n cmm-gperftools -v ${GPERFTOOLS_VERSION} $FPMCOMPRESS_OPT --rpm-changelog "gperftools-${GPERFTOOLS_VERSION}-changelog" --rpm-summary "gperftools-${GPERFTOOLS_VERSION} for centminmod.com LEMP stack installs" --rpm-dist ${DISTTAG}  -m "<centminmod.com>" --description "gperftools-${GPERFTOOLS_VERSION} for centminmod.com LEMP stacks" --url https://centminmod.com --rpm-autoreqprov -p $DIR_TMP -C $GPERFTOOLS_RPMINSTALLDIR

        # check provides and requires
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --provides \"${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --provides "${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo
        
        echo
        echo "-------------------------------------------------------------------------------------"
        echo "rpm -qp --requires \"${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm\""
        rpm -qp --requires "${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm"
        echo "-------------------------------------------------------------------------------------"
        echo

        LINUNWIND_RPMPATH="${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm"
        ls -lah "$LINUNWIND_RPMPATH"
        if [[ "$YUMINSTALL" = [yY] ]]; then
            echo
            echo "yum -y localinstall ${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm"
            yum -y localinstall ${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm
        fi
    if [[ "$YUMINSTALL" = [yY] ]]; then
        echo "yum -y localinstall "${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm""
        yum -y localinstall "${DIR_TMP}/cmm-gperftools-${GPERFTOOLS_VERSION}-1.${DISTTAG}.x86_64.rpm"
    else
        echo
    fi

    echo
    echo "*************************************************"
    cecho "Google gperftools Completed" $boldgreen
    echo "log: ${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
    echo "*************************************************"
}

#########################
case "$1" in
    install )
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            download_files
            install_libunwind
            install_gperftools
            # tidyup
        } 2>&1 | tee "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            echo "Total Google gperftools + libunwind Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
        ;;
    libunwind )
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            download_files
            install_libunwind
            # install_gperftools
            # tidyup
        } 2>&1 | tee "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            echo "Total libunwind Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
        ;;
    gperftools )
            starttime=$(TZ=UTC date +%s.%N)
        {
            fpm_install
            download_files
            # install_libunwind
            install_gperftools
            # tidyup
        } 2>&1 | tee "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            endtime=$(TZ=UTC date +%s.%N)
            INSTALLTIME=$(echo "scale=2;$endtime - $starttime"|bc )
            echo "" >> "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            echo "Total Google gperftools Install Time: $INSTALLTIME seconds" >> "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
            tail -2 "${CENTMINLOGDIR}/gperftools-libunwind_${DT}.log"
        ;;
    * )
        echo
        echo "Usage:"
        echo
        echo "$0 {install|update|libunwind|gperftools}"
        ;;
esac
