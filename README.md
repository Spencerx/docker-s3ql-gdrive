
Proof of concept container. It will automatically mount an image with s3ql with the gdrive patch doing fsck at the begining and umount at the end. It really mounts any storage driver on s3ql, but the objective is to use gdrive and then use this container to get data.

# Requirements

## A Google drive API with API turned ON

You can follow the java example: <https://developers.google.com/drive/v3/web/quickstart/java>, there you can get the `client_id` and `client_secret`.

## A pair of user/passw token

If we have not initialized the drive we can use the commands from the docker image without running it on the default entrypoint:

```
docker run -ti --entrypoint /bin/bash sdelrio/s3ql-gdrive

root@2244484efa00:~# /usr/local/bin/s3ql_oauth_client --oauth_type google-drive --client_id xxxxxxxxxxxxx.apps.googleusercontent.com --client_secret xxxxxxxxxxx
Go to the following link in your browser: https://accounts.google.com/
o/oauth2/v2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive
&access_type=offline&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&
client_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx2.apps.googleuse
rcontent.com&response_type=code
Enter verification code: x/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Successfully retrieved access token
your S3QL Credentials are:
user: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
password: xxxxxxxxxxxxxxxxxxxx:x/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

That user and password is what we will use as the token.

## A filesystem created on the gdrive

Once we have the user and password we will need to run a mkfs the first time. We edit the `/root/.s3ql/authinfo2` with the info we got earlier, the filesystem passphrase that we want and a name for the `storage-url`:

Still inside the container we edit the file like this:

```
[s3ql_backend]
backend-login: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
backend-password: xxxxxxxxxxxxxxxxxxxx:x/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fs-passphrase: 12345667890
storage-url: gdrive://data
```

Now we make a mkfs :

```
root@2244484efa00:~# /usr/local/bin/mkfs.s3ql gdrive://data
```

# Environment vars

- `S3QL_CACHE_ENTRIES`: default 17000
- `S3QL_CACHE_DIR`: default /root/.s3ql
- `S3QL_LOG`: default /root/.s3ql/s3qlmount.log
- `S3QL_TRHEADS`: default 10
- `S3QL_MOUNT`: default `/mnt/data`
- `S3QL_CACHESIZE`: default 10485760 (10GB = 10 * 1024 * 1024)
- `S3QL_METADATA_INTERVAL`: default 21600 (6h = 6 * 60 * 60)
- `S3QL_STORAGE_URL`: default `gdrive://dat`
- `S3QL_USER`: There is no default value. Is the user we got from s3ql_oauth_client
- `S3QL_PASSWORD`: There is no default value. Is the password we got from s3ql_oauth_clien
- `S3QL_FSPP`: There is no default value.
- `S3QL_COMPRESS`: Default `zlib`, you can use `none`. For example, if you will store your jpg backups there is no need to use zlib, but if you will store lot of text or surce code zlib will help.

# Sample docker-compose

```
s3ql-data:
  image: sdelrio/s3ql-gdrive
  cap_add:
    - mknod
    - sys_admin
  devices:
    - /dev/fuse
  privileged: true
  environment:
    - 'S3QL_COMPRESS=none'
    - 'S3QL_MOUNT=/data'
    - 'S3QL_CACHEDIR=/root/.s3ql'
    - 'S3QL_LOG=/root/.s3ql/s3qlmount.log'
    - 'S3QL_THREADS=10'
    - 'S3QL_CACHE_ENTRIES=10000'
    - 'S3QL_CACHESIZE=10000000'
    - 'S3QL_METADATA_INTERVAL=7200'
    - 'S3QL_STORAGE_URL=gdrive://data'
    - 'S3QL_USER=xxxxxxxxxxxxxxxxx'
    - 'S3QL_PASSWORD=xxxxxxxxxxxxxxxx'
    - 'S3QL_FSPP=xxxxxxxxxxxxxxxxxx'
  volumes:
    - '/mnt/data:/data'
```

# References

Base image phusion/baseimage to use startup script /sbin/my_init.

# Known issues

- On filesystem password the sed will use the char `#`for the regexp, so can’t use this char on the password.


