ARG BASE_TAG="develop"
ARG BASE_IMAGE="core-ubuntu-jammy"
FROM kasmweb/$BASE_IMAGE:$BASE_TAG
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# Install Google Chrome
COPY ./install/chrome $INST_SCRIPTS/chrome/
RUN bash $INST_SCRIPTS/chrome/install_chrome.sh  && rm -rf $INST_SCRIPTS/chrome/

# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN cp /usr/share/backgrounds/bg_kasm.png /usr/share/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel

# Security modifications
COPY ./install/misc/single_app_security.sh $INST_SCRIPTS/misc/
RUN  bash $INST_SCRIPTS/misc/single_app_security.sh -t && rm -rf $INST_SCRIPTS/misc/
COPY ./install/chrome-managed-policies/urlblocklist.json /etc/opt/chrome/policies/managed/urlblocklist.json

# Setup the custom startup script that will be invoked when the container starts
#ENV LAUNCH_URL  http://kasmweb.com

COPY ./install/chrome/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh

# Install Custom Certificate Authority
# COPY ./install/certificates $INST_SCRIPTS/certificates/
# RUN bash $INST_SCRIPTS/certificates/install_ca_cert.sh && rm -rf $INST_SCRIPTS/certificates/

ENV KASM_RESTRICTED_FILE_CHOOSER=1
COPY ./install/gtk/ $INST_SCRIPTS/gtk/
RUN bash $INST_SCRIPTS/gtk/install_restricted_file_chooser.sh

# Disable SSL-only mode for compatibility with runtime environment
COPY ./install/vnc/ $INST_SCRIPTS/vnc/
RUN bash $INST_SCRIPTS/vnc/custom_vnc_startup.sh

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000