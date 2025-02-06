# Use an official Ubuntu as a parent image
FROM ubuntu:20.04 AS build-env

# Set environment variables to skip timezone configuration
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Tunis

# Install necessary packages
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    openjdk-17-jdk \
    curl \
    unzip \
    sed \
    git \
    bash \
    xz-utils

# Create directories
RUN mkdir -p /home/developer/android/cmdline-tools && \
    mkdir -p /home/developer/flutter

# Download and install Android command line tools
RUN curl -o android_tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -qq android_tools.zip -d /home/developer/android/cmdline-tools && \
    rm android_tools.zip && \
    mv /home/developer/android/cmdline-tools/cmdline-tools/* /home/developer/android/cmdline-tools/ && \
    rmdir /home/developer/android/cmdline-tools/cmdline-tools

# Accept licenses and install SDK packages
RUN yes | /home/developer/android/cmdline-tools/bin/sdkmanager --sdk_root=/home/developer/android --licenses && \
    yes | /home/developer/android/cmdline-tools/bin/sdkmanager --sdk_root=/home/developer/android "build-tools;33.0.0" "platforms;android-33" "platform-tools" "emulator" "system-images;android-33;google_apis_playstore;x86_64"

# Download and install Flutter SDK
RUN curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.1-stable.tar.xz && \
    tar xf flutter.tar.xz -C /home/developer/flutter --strip-components=1 && \
    rm flutter.tar.xz

# Configure Flutter
RUN /home/developer/flutter/bin/flutter config --no-analytics && \
    /home/developer/flutter/bin/flutter precache && \
    yes "y" | /home/developer/flutter/bin/flutter doctor --android-licenses && \
    /home/developer/flutter/bin/flutter doctor

# Create pub-cache directory
RUN mkdir -p /home/developer/.pub-cache

# Copy entrypoint scripts
COPY entrypoint.sh /usr/local/bin/
COPY flutter-android-emulator.sh /usr/local/bin/

# Set permissions
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/flutter-android-emulator.sh

# Set working directory
WORKDIR /home/developer/flutter-mobile-app

# Final stage
FROM ubuntu:20.04

# Set environment variables to skip timezone configuration
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Africa/Tunis

# Install necessary packages
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    openjdk-17-jdk \
    curl \
    unzip \
    git \
    bash \
    xz-utils

# Copy Flutter and Android SDK from build-env
COPY --from=build-env /home/developer/android /home/developer/android
COPY --from=build-env /home/developer/flutter /home/developer/flutter
COPY --from=build-env /home/developer/.pub-cache /home/developer/.pub-cache

# Copy entrypoint scripts
COPY --from=build-env /usr/local/bin/entrypoint.sh /usr/local/bin/
COPY --from=build-env /usr/local/bin/flutter-android-emulator.sh /usr/local/bin/

# Set working directory
WORKDIR /home/developer/flutter-mobile-app

# Set PATH environment variable
ENV PATH="/home/developer/flutter/bin:/home/developer/android/cmdline-tools/bin:$PATH"

# Run entrypoint script by default
ENTRYPOINT ["entrypoint.sh"]

