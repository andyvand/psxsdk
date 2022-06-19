# Build container to create the toolchain
# Using CentOS 7 for broad compatibility (relatively old glibc)
FROM centos:7

# Install build tools
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y epel-release && yum install -y cmake3 texinfo zlib-devel dpkg
RUN ln -s /usr/bin/cmake3 /usr/bin/cmake