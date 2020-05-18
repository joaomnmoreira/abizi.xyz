=======
Flutter
=======

.. highlight:: console

Install on Windows
------------------

In order to have a working minimal developer environment (aka, without Android Studio installed), i have researched quite a bit on available resources, and with try and error approach i managed to get things working with following setup:

1. Download `flutter <https://flutter.dev/docs/get-started/install/windows#android-setup>`__;
2. Download the older `sdk-tools <https://dl.google.com/android/repository/sdk-tools-windows-4333796.zip>`__ to 'D:\\Develop\\android\\sdk'. Could not make it with Command Line Tools latest version (at the time of writing 'commandlinetools-win-6200805_latest.zip');
3. Download `Adoptopenjdk 8 (LTS) version <https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09.1/OpenJDK8U-jdk_x64_windows_hotspot_8u252b09.zip>`__ to 'D:\\Develop\\adoptopenjdk-8';
4. Create the following user environment variables:

.. list-table:: Environment Variables
   :widths: 25 25
   :header-rows: 1

   * - Variable
     - Value
   * - ANDROID_HOME
     - D:\\Develop\\android
   * - ANDROID_SDK_ROOT
     - D:\\Develop\\android\\sdk
   * - FLUTTER_HOME
     - D:\\Develop\\flutter
   * - JAVA_HOME
     - D:\\Develop\\adoptopenjdk-8
   * - Path
     - %ANDROID_HOME%
       %FLUTTER_HOME%\\bin
       %ANDROID_SDK_ROOT%
       %ANDROID_SDK_ROOT%\\bin
       %JAVA_HOME%\\bin

5. Install `VS Code and Flutter/Dart plugins <https://flutter.dev/docs/get-started/editor?tab=vscode>`__;
6. Open a command prompt/powershell and check if android sdk tools work:

::

    sdkmanager --list

7. Run flutter doctor to verify dependecy problems:

::

    flutter doctor -v

8. Install Android SDK:

::

    sdkmanager --install "system-images;android-27;default;x86_64" "platform-tools" "platforms;android-29" "build-tools;29.0.2" "platforms;android-28" "build-tools;28.0.3" emulator extras;intel;Hardware_Accelerated_Execution_Manager

- References:

    - `Install-android-sdk-on-windows-10-without-android-studio <https://cloudreports.net/install-android-sdk-on-windows-10-without-android-studio/>`__
    - `Install-flutter-without-android-studio <https://www.majed-learn.com/en/post/install-flutter-without-android-studio/>`__
    - `Sdk-tools enabler version <https://stackoverflow.com/questions/37505709/how-do-i-download-the-android-sdk-without-downloading-android-studio>`__
    - `Adoptopenjdk <https://adoptopenjdk.net/>`__