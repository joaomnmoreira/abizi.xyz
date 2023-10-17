
=================
vsftp + s3 bucket
=================

.. highlight:: console

Readme
======

https://github.com/s3fs-fuse/s3fs-fuse/
https://security.appspot.com/vsftpd.html
https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-20-04

s3fs-fuse Base
==============

.../roles/1-s3fs/defaults/main.yml

.. code-block:: yaml

    ---
    s3fs_source_url: "https://github.com/s3fs-fuse/s3fs-fuse.git"
    s3fs_tmp_dir: "/tmp/s3fs-fuse"

    s3fs_update: false

.../roles/1-s3fs/tasks/0-dependencies.yml

.. code-block:: yaml

    ---
    - name: Autoclean, autoremove, update cache, install packages
    apt:
        force_apt_get: yes
        autoclean: yes
        autoremove: yes
        update_cache: yes
        cache_valid_time: 1800
        pkg: "{{ packages }}"
        state: latest
    vars:
        packages:
        - automake
        - autotools-dev
        - fuse
        - g++
        - git
        - libcurl4-openssl-dev
        - libfuse-dev
        - libssl-dev
        - libxml2-dev
        - make
        - pkg-config
    register: s3fs_dependencies

    - name: Apt upgrade
    apt:
        upgrade: yes

.../roles/1-s3fs/tasks/01-install.yml

.. code-block:: yaml

    ---
    - name: Check s3fs Installation
    shell: "which s3fs"
    register: s3fs_check_install
    ignore_errors: true
    changed_when: false

    - name: debug s3fs
    debug:
        msg: s3fs_check_install

    - name: Install S3FS block
    block:
        - name: Downloading S3FS source
        git:
            repo: "{{ s3fs_source_url }}"
            dest: "{{ s3fs_tmp_dir }}"
        register: s3fs_source_clone

        - name: ./autogen.sh S3FS
        command: "./autogen.sh"
        args:
            chdir: "{{ s3fs_tmp_dir }}"
        when:
            - s3fs_dependencies is success
            - s3fs_source_clone is success
        register: s3fs_autogen

        - name: ./configure S3FS
        command: "./configure"
        args:
            chdir: "{{ s3fs_tmp_dir }}"
        when: s3fs_autogen is success
        register: s3fs_configure

        - name: Make S3FS
        command: "make"
        args:
            chdir: "{{ s3fs_tmp_dir }}"
        when: s3fs_configure is success
        register: s3fs_make

        - name: Make Install S3FS
        command: "make install"
        args:
            chdir: "{{ s3fs_tmp_dir }}"
        when: s3fs_make is success
        register: s3fs_makeinstall

    when: "'/usr/local/bin/s3fs' not in s3fs_check_install.stdout or s3fs_update"

.../roles/1-s3fs/tasks/main.yml

.. code-block:: yaml

    ---
    - include_tasks: 0-dependencies.yml
    - include_tasks: 01-install.yml

vsFTPd Base
===========

.../roles/1-vsftpd/defaults/main.yml

.. code-block:: yaml

    ---
    ftp_group: ftponly
    vsftpd_userlist: "/etc/vsftpd.userlist"

.../roles/1-vsftpd/files/ftponly

.. code-block:: bash

    #!/bin/sh
    echo "This account is limited to FTP access only."

.../roles/1-vsftpd/handlers/main.yml

.. code-block:: yaml

    --- 
    - name: Restart vsftpd
    service:
        name: vsftpd
        enabled: yes
        state: restarted

    - name: Reload vsftpd
    service:
        name: vsftpd
        state: reloaded

.../roles/1-vsftpd/tasks/0-dependencies.yml

.. code-block:: yaml

    ---
    - name: Autoclean, autoremove, update cache, install VSFTPD
    apt:
        force_apt_get: yes
        autoclean: yes
        autoremove: yes
        update_cache: yes
        cache_valid_time: 1800
        pkg: "{{ packages }}"
        state: latest
    vars:
        packages:
        - vsftpd

    - name: Apt upgrade
    apt:
        upgrade: yes

.../roles/1-vsftpd/tasks/1-configure.yml

.. code-block:: yaml

    ---
    #
    # Group and shell requisites
    #
    - name: Create FTP group
    group:
        name: "{{ ftp_group }}"
        system: yes
        state: present

    - name: Add custom/restricted shell /bin/{{ ftp_group }}
    template:
        src: "files/{{ ftp_group }}"
        dest: "/bin/{{ ftp_group }}"
        owner: root
        group: root

    - name: Add /bin/{{ ftp_group }} to /bin/shells
    ansible.builtin.lineinfile:
        path: /etc/shells
        line: /bin/{{ ftp_group }}

    #
    # /etc/vsftpd.userlist requisites
    #
    - name: Create {{ vsftpd_userlist }} file
    file:
        path: "{{ item }}"
        state: touch
    with_items:
        - "{{ vsftpd_userlist }}"

    #
    # vsftpd.conf
    #
    - name: Add custom VSFTPD CONF files
    template:
        src: "{{ item }}.j2"
        dest: "/etc/{{ item }}"
        owner: root
        group: root
        mode: 0644
    with_items:
        - vsftpd.conf
    notify: Restart vsftpd

    - name: force all notified handlers to run at this point, not waiting for normal sync points
    meta: flush_handlers

.../roles/1-vsftpd/tasks/main.yml

.. code-block:: yaml

    ---
    - include_tasks: 0-dependencies.yml
    - include_tasks: 1-configure.yml

.../roles/1-vsftpd/templates/vsftpd.conf.j2

.. code-block:: bash

    # Example config file /etc/vsftpd.conf
    #
    # The default compiled in settings are fairly paranoid. This sample file
    # loosens things up a bit, to make the ftp daemon more usable.
    # Please see vsftpd.conf.5 for all compiled in defaults.
    #
    # READ THIS: This example file is NOT an exhaustive list of vsftpd options.
    # Please read the vsftpd.conf.5 manual page to get a full idea of vsftpd's
    # capabilities.
    #
    #
    # Run standalone?  vsftpd can run either from an inetd or as a standalone
    # daemon started from an initscript.
    listen=NO
    #
    # This directive enables listening on IPv6 sockets. By default, listening
    # on the IPv6 "any" address (::) will accept connections from both IPv6
    # and IPv4 clients. It is not necessary to listen on *both* IPv4 and IPv6
    # sockets. If you want that (perhaps because you want to listen on specific
    # addresses) then you must run two copies of vsftpd with two configuration
    # files.
    listen_ipv6=YES
    #
    # Allow anonymous FTP? (Disabled by default).
    anonymous_enable=NO
    #
    # Uncomment this to allow local users to log in.
    local_enable=YES
    #
    # Uncomment this to enable any form of FTP write command.
    write_enable=YES
    #
    # Default umask for local users is 077. You may wish to change this to 022,
    # if your users expect that (022 is used by most other ftpd's)
    local_umask=022
    #
    # Uncomment this to allow the anonymous FTP user to upload files. This only
    # has an effect if the above global write enable is activated. Also, you will
    # obviously need to create a directory writable by the FTP user.
    #anon_upload_enable=YES
    #
    # Uncomment this if you want the anonymous FTP user to be able to create
    # new directories.
    #anon_mkdir_write_enable=YES
    #
    # Activate directory messages - messages given to remote users when they
    # go into a certain directory.
    dirmessage_enable=YES
    #
    # If enabled, vsftpd will display directory listings with the time
    # in  your  local  time  zone.  The default is to display GMT. The
    # times returned by the MDTM FTP command are also affected by this
    # option.
    use_localtime=YES
    #
    #
    # Make sure PORT transfer connections originate from port 20 (ftp-data).
    connect_from_port_20=YES
    #
    # If you want, you can arrange for uploaded anonymous files to be owned by
    # a different user. Note! Using "root" for uploaded files is not
    # recommended!
    #chown_uploads=YES
    #chown_username=whoever
    #
    # You may change the default value for timing out an idle session.
    #idle_session_timeout=600
    #
    # You may change the default value for timing out a data connection.
    #data_connection_timeout=120
    #
    # It is recommended that you define on your system a unique user which the
    # ftp server can use as a totally isolated and unprivileged user.
    #nopriv_user=ftpsecure
    #
    # Enable this and the server will recognise asynchronous ABOR requests. Not
    # recommended for security (the code is non-trivial). Not enabling it,
    # however, may confuse older FTP clients.
    #async_abor_enable=YES
    #
    # By default the server will pretend to allow ASCII mode but in fact ignore
    # the request. Turn on the below options to have the server actually do ASCII
    # mangling on files when in ASCII mode.
    # Beware that on some FTP servers, ASCII support allows a denial of service
    # attack (DoS) via the command "SIZE /big/file" in ASCII mode. vsftpd
    # predicted this attack and has always been safe, reporting the size of the
    # raw file.
    # ASCII mangling is a horrible feature of the protocol.
    #ascii_upload_enable=YES
    #ascii_download_enable=YES
    #
    # You may fully customise the login banner string:
    #ftpd_banner=Welcome to blah FTP service.
    #
    # You may specify a file of disallowed anonymous e-mail addresses. Apparently
    # useful for combatting certain DoS attacks.
    #deny_email_enable=YES
    # (default follows)
    #banned_email_file=/etc/vsftpd.banned_emails
    #
    # You may restrict local users to their home directories.  See the FAQ for
    # the possible risks in this before using chroot_local_user or
    # chroot_list_enable below.
    chroot_local_user=YES
    #
    # You may specify an explicit list of local users to chroot() to their home
    # directory. If chroot_local_user is YES, then this list becomes a list of
    # users to NOT chroot().
    # (Warning! chroot'ing can be very dangerous. If using chroot, make sure that
    # the user does not have write access to the top level directory within the
    # chroot)
    #chroot_local_user=YES
    #chroot_list_enable=YES
    # (default follows)
    #chroot_list_file=/etc/vsftpd.chroot_list
    #
    # You may activate the "-R" option to the builtin ls. This is disabled by
    # default to avoid remote users being able to cause excessive I/O on large
    # sites. However, some broken FTP clients such as "ncftp" and "mirror" assume
    # the presence of the "-R" option, so there is a strong case for enabling it.
    #ls_recurse_enable=YES
    #
    # Customization
    #
    # Some of vsftpd's settings don't fit the filesystem layout by
    # default.
    #
    # This option should be the name of a directory which is empty.  Also, the
    # directory should not be writable by the ftp user. This directory is used
    # as a secure chroot() jail at times vsftpd does not require filesystem
    # access.
    secure_chroot_dir=/var/run/vsftpd/empty
    #
    # This string is the name of the PAM service vsftpd will use.
    pam_service_name=vsftpd
    #
    # This option specifies the location of the RSA certificate to use for SSL
    # encrypted connections.
    rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
    rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
    ssl_enable=YES

    #
    # Uncomment this to indicate that vsftpd use a utf8 filesystem.
    utf8_filesystem=YES

    #
    # Customization
    #
    #
    allow_writeable_chroot=YES
    #
    user_sub_token=$USER
    local_root=/home/$USER/ftp
    #
    pasv_enable=YES
    pasv_min_port=30000
    pasv_max_port=40000
    #
    listen_port=35000
    #
    userlist_enable=YES
    userlist_file={{ vsftpd_userlist }}
    userlist_deny=NO
    #
    ssl_tlsv1=YES
    ssl_sslv2=NO
    ssl_sslv3=NO
    ssl_ciphers=HIGH
    allow_anon_ssl=NO
    force_local_data_ssl=YES
    force_local_logins_ssl=YES
    require_ssl_reuse=NO
    strict_ssl_read_eof=NO
    #
    ### LOGGING
    #
    # log_ftp_protocol: When enabled, all FTP requests and responses are logged, providing the option xferlog_std_format
    # Default: NO
    log_ftp_protocol=YES
    #
    # If true, OpenSSL connection diagnostics are dumped to the vsftpd log file. (Added in v2.0.6).
    # Default: NO
    debug_ssl=YES
    #
    # When enabled in conjunction with xferlog_enable, vsftpd writes two files simultaneously: a wu-ftpd-compatible log t
    # xferlog_file directive (/var/log/xferlog by default) and a standard vsftpd log file specified in the vsftpd_log_fil
    # The default value is NO.
    dual_log_enable=YES
    #
    # Activate logging of uploads/downloads.
    # Enables recording of transfer stats to /var/log/vsftpd.log
    xferlog_enable=YES
    #
    # You may override where the log file goes if you like. The default is shown
    # below.
    #xferlog_file=/var/log/vsftpd.log
    #
    # If you want, you can have your log file in standard ftpd xferlog format.
    # Note that the default log file location is /var/log/xferlog in this case.
    xferlog_std_format=YES

s3fs-fuse + vsFTPd Configuration
================================

.../roles/8-service_gwftp/defaults/main.yml

.. code-block:: yaml

    ---
    # Equal to 'ansible/_roles/89-letsencrypt-service-sync/defaults/main.yml'
    domains_list: "/etc/domains.list"

    # Equal to 'ansible/_roles/1-vsftpd/defaults/main.yml'
    ftp_group: ftponly
    vsftpd_userlist: "/etc/vsftpd.userlist"

    # Needed for S3FS Access
    passwd_s3fs: "/etc/passwd-s3fs"

    # S3FS Parameteres
    s3fs_del_cache: "del_cache"                           # Delete local file cache when s3fs starts and exits
    s3fs_use_cache: "use_cache=/tmp/s3fs-cache"           # Local folder to use for local file cache.
    s3fs_stat_cache_expire: "stat_cache_expire=86400"     # Specify expire time (seconds) for entries in the stat cache and symbolic link cache. This expire time indicates the time since cached.
    s3fs_ensure_diskfree: "ensure_diskfree=10240"         # Sets MB to ensure disk free space. This option means the threshold of free space size on disk which is used for the cache file by s3fs.  s3fs makes file for downloading, uploading and caching files.  If the disk  free
                                                          # space is smaller than this value, s3fs do not use diskspace as possible in exchange for the performance.
    s3fs_allow_other: "allow_other"                       # If allow_other option is not set, s3fs allows access to the mount point only to the owner.  In the opposite case s3fs allows access to all users as the default.
    s3fs_host: "host="                                    # Set a non-Amazon host
    s3fs_use_path_request_style: "use_path_request_style"
    s3fs_mp_umask: "0022"

    #
    # Password Generation:
    # mkpasswd --method=sha-512 (apt install whois)
    #
    ftp_user_data:
    - username: "<username>"
        password: "<generated hash>"
        bucket_s3: "<bucket name>"
        digitalocean_access_key_id: "<s3 access key id>"
        digitalocean_secret_access_key: "<s3 secret access key>"
        digitalocean_s3_region: "<s3 url endpoint>"
        files_dir: false
        domain: "<domain>"

.../roles/8-service_gwftp/handlers/main.yml

.. code-block:: yaml

    ---
    - block:

    - name: Reload fstab
        command: mount -a

    - name: Restart vsftpd
        service:
        name: vsftpd
        enabled: yes
        state: restarted

    become_user: root

.../roles/8-service_gwftp/tasks/0-users.yml

.. code-block:: yaml

    ---
    - name: Get {{ user_item.username }} user info
    getent:
        database: passwd
        key: "{{ user_item.username }}"
    ignore_errors: true

    - debug:
        var: getent_passwd

    - block:
    - name: Add user {{ user_item.username }} to ftp group
        user:
        name: "{{ user_item.username }}"
        append: yes
        groups: "{{ ftp_group }}"

    - name: Create user {{ user_item.username }}
        user:
        name: "{{ user_item.username }}"
        shell: "/bin/{{ ftp_group }}"
        group: "{{ ftp_group }}"
        home: "/home/{{ user_item.username }}"
        password: "{{ user_item.password }}"

    - name: Create FTP root directory - /home/{{ user_item.username }}/ftp
        file:
        path: "{{ item }}"
        state: directory
        owner: nobody
        group: nogroup
        with_items:
        - "/home/{{ user_item.username }}/ftp"

    - name: Create FILES directory - /home/{{ user_item.username }}/ftp/files
        file:
        path: "{{ item }}"
        state: directory
        owner: "{{ user_item.username }}"
        group: "{{ ftp_group }}"
        with_items:
        - "/home/{{ user_item.username }}/ftp/files"
        when: "{{ user_item.files_dir }}"

    #
    # /etc/vsftpd.userlist workflow
    #

    - name: Add {{ user_item.username }} in {{ vsftpd_userlist }}
        ansible.builtin.lineinfile:
        path: "{{ vsftpd_userlist }}"
        line: "{{ user_item.username }}"
    when: getent_passwd is undefined

.../roles/8-service_gwftp/tasks/1-s3fs.yml

.. code-block:: yaml

    ---
    #
    # S3FS requisites
    #
    - name: Create {{ passwd_s3fs }} file
        file:
        path: "{{ item }}"
        state: touch
        mode: 0640
        with_items:
        - "{{ passwd_s3fs }}"

    - name: Build {{ passwd_s3fs }}
        ansible.builtin.lineinfile:
        path: "{{ passwd_s3fs }}"
        line: "{{ user_item.bucket_s3 }}:{{ user_item.digitalocean_access_key_id }}:{{ user_item.digitalocean_secret_access_key }}"

    - name: Create fstab line
        set_fact:
        fstab_line: "{{ user_item.bucket_s3 }} /home/{{ user_item.username }}/ftp/{{ user_item.bucket_s3 }} fuse.s3fs _netdev,{{ s3fs_del_cache }},{{ s3fs_use_cache }},{{ s3fs_stat_cache_expire }},{{ s3fs_ensure_diskfree  }},{{ s3fs_allow_other }},{{ s3fs_use_path_request_style }},{{ s3fs_host }}{{ user_item.digitalocean_s3_region }},mp_umask={{ s3fs_mp_umask }} 0 0"
        when: getent_passwd[user_item.username] is not defined or (getent_passwd[user_item.username][1] is not defined and getent_passwd[user_item.username][2] is not defined)

    - name: Create fstab line with uid and gid
        set_fact:
        fstab_line: "{{ user_item.bucket_s3 }} /home/{{ user_item.username }}/ftp/{{ user_item.bucket_s3 }} fuse.s3fs _netdev,{{ s3fs_del_cache }},{{ s3fs_use_cache }},{{ s3fs_stat_cache_expire }},{{ s3fs_ensure_diskfree  }},{{ s3fs_allow_other }},{{ s3fs_use_path_request_style }},{{ s3fs_host }}{{ user_item.digitalocean_s3_region }},mp_umask={{ s3fs_mp_umask }},uid={{ getent_passwd[user_item.username][1] }},gid={{ getent_passwd[user_item.username][2] }} 0 0"
        when: getent_passwd[user_item.username] is defined and getent_passwd[user_item.username][1] is defined and getent_passwd[user_item.username][2] is defined

    - name: Build /etc/fstab
        ansible.builtin.lineinfile:
        path: "/etc/fstab"
        line: "{{ fstab_line }}"
        notify:
        - Reload fstab

.../roles/8-service_gwftp/tasks/2-domain_cert.yml

.. code-block:: yaml

    ---
    - name: Create {{ domains_list }} file
        file:
        path: "{{ item }}"
        state: touch
        mode: 0640
        with_items:
        - "{{ domains_list }}"

    - name: Build {{ domains_list }}
        ansible.builtin.lineinfile:
        path: "{{ domains_list }}"
        line: "{{ user_item.domain }}"

    - name: Update rsa settings in vsftpd.conf
        ansible.builtin.lineinfile:
        path: /etc/vsftpd.conf
        regexp: '{{ item.regexp }}'
        line: '{{ item.line }}'
        with_items:
        - { regexp: '^rsa_cert_file=', line: 'rsa_cert_file=/etc/ssl/private/{{ user_item.domain }}/fullchain.pem' }
        - { regexp: '^rsa_private_key_file=', line: 'rsa_private_key_file=/etc/ssl/private/{{ user_item.domain }}/privkey.pem' }
        notify: Restart vsftpd

.../roles/8-service_gwftp/tasks/main.yml

.. code-block:: yaml

    ---
    - include_tasks: 0-users.yml
    with_items: "{{ ftp_user_data }}"
    loop_control:
        loop_var: user_item
    - include_tasks: 1-s3fs.yml    
    with_items: "{{ ftp_user_data }}"
    loop_control:
        loop_var: user_item
    - include_tasks: 2-domain_cert.yml    
    with_items: "{{ ftp_user_data }}"
    loop_control:
        loop_var: user_item

Commands
========

Manually mounting Point Owner/Permissions OK

::

    /usr/local/bin/s3fs vsports-wsc /home/<username>/ftp/<bucket> -o url="https://ams3.digitaloceanspaces.com" -o allow_other -o use_cache="/tmp/s3fs-cache" -o del_cache -o stat_cache_expire=86400 -o ensure_diskfree=10240 -o use_path_request_style -o uid=<username uid> -o gid=<username gid> -o umask=0022 -o curldbg 

Lazy unmount

::

    umount -l /home/wsc/ftp/vsports-wsc/

Force unmount

::

    umount -f /home/wsc/ftp/vsports-wsc/

Logs

::

    tail -f /var/log/xferlog 
    tail -f /var/log/vsftpd.log
    tail -f /var/log/syslog | grep s3fs