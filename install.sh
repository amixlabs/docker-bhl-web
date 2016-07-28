#!/usr/bin/env bash

setup() {
	export http_proxy https_proxy
}

download() {

	local files urls

	files=(
		'oracle-instantclient-basic-10.2.0.5-1.x86_64.rpm'
		'oracle-instantclient-devel-10.2.0.5-1.x86_64.rpm'
		'jre-6u45-linux-x64-rpm.bin'
		'fop-1.0-bin.zip'
		'iSeriesAccess-5.4.0-1.6.x86_64.rpm'
		'freetds-stable.tgz'
	)
	urls=(
		'https://www.dropbox.com/s/6jz75afu3pvdzv8/oracle-instantclient-basic-10.2.0.5-1.x86_64.rpm?dl=0'
		'https://www.dropbox.com/s/ijd0wb8s6na85vn/oracle-instantclient-devel-10.2.0.5-1.x86_64.rpm?dl=0'
		'https://www.dropbox.com/s/dhy2v8cof3x5d2j/jre-6u45-linux-x64-rpm.bin?dl=0'
		'https://www.dropbox.com/s/9ykm2bp7tg9ujp6/fop-1.0-bin.zip?dl=0'
		'https://www.dropbox.com/s/as47wy3g0y2yp41/iSeriesAccess-5.4.0-1.6.x86_64.rpm?dl=0'
		'https://www.dropbox.com/s/3s8uhjh8isap4j3/freetds-stable.tgz?dl=0'
	)
  yum install -y curl &&
  download_files
}

download_files() {

	local file url n

	n=${#files[@]}
	for ((i=0; i < n; i++)); do
		file="${files[$i]}"
		url=${urls[$i]}
		if [[ ! -r $file ]]; then
			if ! curl -Lo "$file" "$url"; then
				return 1
			fi
		fi
		if [[ -r $file ]]; then
			echo "$file: ok"
		fi
	done
}

update() {
	yum update -y
}

install_tools() {
	yum install -y \
		gcc \
		make \
		yum-utils \
		unzip
}

install_odbc() {
	yum install -y \
		unixODBC \
		unixODBC-devel
}

install_oracle() {
	rpm -ivh oracle-instantclient-*.rpm
	(cd /usr/include/oracle/10.2.0.5 && ln -fs client64 client)
	(cd /usr/lib/oracle/10.2.0.5 && ln -fs client64 client)
}

install_iseries() {
	yum install -y compat-libstdc++-33
	rpm -q iSeriesAccess ||
	rpm -ivh iSeriesAccess-5.4.0-1.6.x86_64.rpm
}

install_freetds() (
	[[ -d freetds-0.91 ]] || tar xzvf freetds-stable.tgz
	cd freetds-0.91/ || return 1
	[[ -d /usr/local/include/freetds ]] || {
		./configure --with-unixodbc=/usr/ --with-tdsver=7.0 &&
		make &&
		make install &&
		cp -fa include /usr/local/include/freetds
	}
)

install_jre() {
	for rpm in jre-6u45-linux-*.rpm; do
		[[ -r $rpm ]] &&
		rm -f "$rpm"
	done
	rpm -q jre || bash jre-6u45-linux-x64-rpm.bin
}

install_fop() (
	[[ -d /usr/java/fop-1.0 ]] || {
		unzip fop-1.0-bin.zip -d /usr/java/ || return 1
		cd /usr/java || return 1
		ln -fs fop-1.0 fop
		chmod +x /usr/java/fop/fop
	}
)

install_httpd() {
	yum install -y httpd
}

install_php() {
	yum install -y \
		php \
		php-soap \
		php-pdo \
		php-odbc \
		php-mbstring \
		php-common \
		php-pgsql \
		php-cli \
		php-readline \
		php-xml \
		php-ldap \
		php-tidy \
		php-devel
}

install_php_source() (
	[[ -d php/php-5.1.6 ]] && return 0
	yumdownloader --source php
	[[ -d php ]] || mkdir php && cd php || return 1
	rpm2cpio ../php-5.1.6-45.el5_11.src.rpm | cpio -idmv --no-absolute-filenames
	tar xzvf php-5.1.6.tar.gz
)

install_pdo_oci() (
	[[ -r /etc/php.d/pdo_oci.ini && -r /usr/lib64/php/modules/pdo_oci.so ]] && return 0
	cd php/php-5.1.6/ext/pdo_oci/ || return 1
	phpize
	./configure --with-pdo-oci=instantclient,/usr,10.2.0.5
	make
	make install
	tee /etc/php.d/pdo_oci.ini <<-"EOT"
	; Enable pdo_oci extension module
	extension=pdo_oci.so
	EOT
)

install_pdo_dblib() (
	[[ -r /etc/php.d/pdo_dblib.ini && -r /usr/lib64/php/modules/pdo_dblib.so ]] && return 0
	cd php/php-5.1.6/ext/pdo_dblib/ || return 1
	# Ajustando link entre arquivos
	ln -fs /usr/local/lib/libsybdb.so /usr/local/lib/libtds.so
	# Compilando
	phpize
	./configure --with-pdo-dblib=/usr/local/
	make
	make install
	tee /etc/php.d/pdo_dblib.ini <<-"EOT"
	; Enable pdo_dblib extension module
	extension=pdo_dblib.so
	EOT
)

install() {
	update &&
	install_tools &&
	install_odbc &&
	install_oracle &&
	install_iseries &&
	install_freetds &&
	install_jre &&
	install_fop &&
	install_httpd &&
	install_php &&
	install_php_source &&
	install_pdo_oci &&
	install_pdo_dblib
}

cleanup() {
	yum clean all &&
	rm -rf /tmp/* &&
  find /var/tmp /var/cache /var/log -type f -delete
}

main() {
  cd /tmp/ || return 1
	setup &&
  download &&
  install &&
  cleanup &&
  mkdir /app
}

main "$@"
