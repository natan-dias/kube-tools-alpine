FROM golang:alpine AS jid 
RUN apk add git
RUN go get -u github.com/simeji/jid/cmd/jid

#Bretfisher HTTPING-DOCKER - GIT: BretFisher/httping-docker
#Based on Vanheusden HTTPING - URL: http://www.vanheusden.com
FROM alpine AS httping-build 

RUN apk add --no-cache \
    make \
    build-base \ 
    openssl-dev \
    openssl-libs-static \
    ncurses-dev \
    ncurses-static \
    gettext-dev \
    gettext-static \
    fftw-dev \
    fftw-double-libs \
    fftw-long-double-libs

WORKDIR /source

COPY httping-source .

# make a static binary, and link in gettext
ENV LDFLAGS="-static -lintl"

RUN ./configure --with-tfo --with-ncurses --with-openssl --with-fftw3 && make

#Base Image ALPINE
FROM alpine
ENV COMPLETIONS=/usr/shar/bash-completion/completions
RUN apk add bash bash-completion curl git jq libintl ncurses openssl tmux vim apache2-utils nmap

#DOCKER-COMPOSE
RUN mkdir -p /root/.docker/cli-plugins \
	curl sSLo /root/.docker/cli-plugins/docker-compose https://github.com/docker/compose-cli/releases/tag/v2.0.0-rc.1/docker-compose-linux-amd64 \
	chmod +x /root/.docker/cli-plugins/docker-compose

#DOCKER CLI
COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker

#KUBECTL
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#HTTPING
COPY --from=httping-build /source/httping /usr/local/bin/httping

#JID
COPY --from=jid /go/bin/jid /usr/local/bin/jid

# final shell environment prep
WORKDIR /root
RUN echo trap exit TERM > /etc/profile.d/trapterm.sh
RUN sed -i "s/export PS1=/#export PS1=/" /etc/profile
RUN sed -i s,/bin/ash,/bin/bash, /etc/passwd
ENV HOSTIP="0.0.0.0" \
    TERM="xterm-256color" \
    KUBE_PS1_PREFIX="" \
    KUBE_PS1_SUFFIX="" \
    KUBE_PS1_SYMBOL_ENABLE="false" \
    KUBE_PS1_CTX_COLOR="green" \
    KUBE_PS1_NS_COLOR="green"
ENV PS1="\e[1m\e[31m[\$HOSTIP] \e[32m(\$(kube_ps1)) \e[34m\u@\h\e[35m \w\e[0m\n$ "
CMD ["bash", "-l"]
