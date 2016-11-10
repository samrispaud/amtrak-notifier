FROM centos:7

ENV RUBY_VERSION 2.2.3
ENV PHANTOMJS_VERSION 1.9.8

# find URL and SHA256 on http://phantomjs.org/download.html
ENV PHANTOMJS_DOWNLOAD_URL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2
ENV PHANTOMJS_DOWNLOAD_SHA256 a1d9628118e270f26c4ddd1d7f3502a93b48ede334b8585d11c1c3ae7bc7163a

# install general pre-requisites
RUN yum install -y epel-release
RUN yum install -y tar bzip2 git sqlite make gcc gcc-c++ ruby-devel zlib-devel postgresql-devel cmake openssh-client libxml2-devel libxslt-devel nodejs npm

# installing webkit - useful for CI webapps
RUN yum install -y qtwebkit-devel
RUN ln -s /usr/lib64/qt4/bin/qmake /usr/bin/qmake

# INSTALL RUBY & rubygems
RUN yum install -y ruby-$RUBY_VERSION rubygems
RUN gem install bundler rspec rails:4.2.7

# INSTALL PHANTOMJS
RUN yum install -y fontconfig freetype freetype-devel fontconfig-devel libstdc++

RUN mkdir -p /opt/phantomjs/
RUN curl -fsSL "$PHANTOMJS_DOWNLOAD_URL" -o phantomjs.tar.bz2
RUN echo "$PHANTOMJS_DOWNLOAD_SHA256 phantomjs.tar.bz2" | sha256sum -c -
RUN tar -xvf phantomjs.tar.bz2 -C /opt/phantomjs
RUN rm phantomjs.tar.bz2

ENV PATH $PATH:/opt/phantomjs/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/bin/
