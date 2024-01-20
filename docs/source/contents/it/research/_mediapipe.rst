Saliency-aware Video Cropping
AutoFlip: An Open Source Framework for Intelligent Video Reframing

https://reframer.ai/
https://www.horatio.cloud/
https://2short.ai/
https://glossai.co/
https://www.editair.app/
https://klap.app/
https://vidyo.ai/
https://nablet.com/shrynk
https://roboflow.com/

https://pacavaca.medium.com/poor-mans-intelligent-reframing-for-gopro-videos-c9bb489512db
https://gist.github.com/bsod90/fbeca5fd3d021e43aead278d176f07fb

https://medium.com/@maciek99/unlocking-the-power-of-yolov8-in-python-auto-reframe-aka-smart-video-crop-c30644c34481


https://medium.com/@issam.jebnouni/yolov8-object-detection-for-football-543d5e704b57
https://github.com/0xrushi/Soccer-Player-Tracking-YoloV5

==================
Mediapipe (google)
==================
.. highlight:: console

Method #1: Local Install
========================

- https://google.github.io/mediapipe/getting_started/install.html


https://google.github.io/mediapipe/getting_started/install.html

1. Install Bazelisk
https://github.com/bazelbuild/bazelisk

wget https://github.com/bazelbuild/bazelisk/releases/download/v1.15.0/bazelisk-linux-amd64
chmod +x bazelisk-linux-amd64
sudo mv bazelisk-linux-amd64 /usr/local/bin/bazel

2. Checkout MediaPipe repository
https://google.github.io/mediapipe/getting_started/install.html

$ cd /usr/local/etc/
$ git clone https://github.com/google/mediapipe.git
$ cd mediapipe

3. Install OpenCV and FFmpeg

$ sudo apt-get install -y \
    libopencv-core-dev \
    libopencv-highgui-dev \
    libopencv-calib3d-dev \
    libopencv-features2d-dev \
    libopencv-imgproc-dev \
    libopencv-video-dev

$ sudo pip install numpy

4. For running desktop examples on Linux only (not on OS X) with GPU acceleration	

$ sudo apt-get install mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev

# To compile with GPU support, replace
--define MEDIAPIPE_DISABLE_GPU=1
# with
--copt -DMESA_EGL_NO_X11_HEADERS --copt -DEGL_NO_X11
# when building GPU examples.

5. Run the Hello World! in C++ example

$ export GLOG_logtostderr=1

# if you are running on Linux desktop with CPU only
$ bazel run --define MEDIAPIPE_DISABLE_GPU=1 \
    mediapipe/examples/desktop/hello_world:hello_world
	
# If you are running on Linux desktop with GPU support enabled (via mesa drivers)
$ bazel run --copt -DMESA_EGL_NO_X11_HEADERS --copt -DEGL_NO_X11 \
    mediapipe/examples/desktop/hello_world:hello_world

# Should print:
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!
# Hello World!

Autoflip
https://google.github.io/mediapipe/solutions/autoflip

1. Build Autoflip

$ cd /usr/local/etc/mediapipe
$ sudo chown -R root:webapps .
$ sudo chmod -R g+w .

-------------------------> $ sudo apt install libopencv-contrib-dev

$ bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 --copt -I/usr/include/opencv4/ mediapipe/examples/desktop/autoflip:run_autoflip

2. Running Autoflip
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_1.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_1_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_1.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_1_9_16.mp4,aspect_ratio=9:16
---------
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_2.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_2_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_2.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_2_9_16.mp4,aspect_ratio=9:16
---------
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_3.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_3_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_3.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_3_9_16.mp4,aspect_ratio=9:16

2. Running Autoflip: development.pbtxt

GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip \
--calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt \
--input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_1.mp4,\
aspect_ratio=1:1,\
output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_1_1_1.mp4,\
key_frame_crop_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_1_1_1_key_frame_crop_viz_frames.mp4,\
salient_point_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_1_1_1_salient_point_viz_frames.mp4

GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip \
--calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt \
--input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_1.mp4,\
aspect_ratio=9:16,\
output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_1_9_16.mp4,\
key_frame_crop_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_1_9_16_key_frame_crop_viz_frames.mp4,\
salient_point_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_1_9_16_salient_point_viz_frames.mp4

---------
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip \
--calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt \
--input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_2.mp4,\
aspect_ratio=1:1,\
output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_2_1_1.mp4,\
key_frame_crop_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_2_1_1_key_frame_crop_viz_frames.mp4,\
salient_point_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_2_1_1_salient_point_viz_frames.mp4

GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip \
--calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt \
--input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_2.mp4,\
aspect_ratio=9:16,\
output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_2_9_16.mp4,\
key_frame_crop_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_2_9_16_key_frame_crop_viz_frames.mp4,\
salient_point_viz_frames_path=/opt/sportmultimedia/outputs/output/local_highlight_2_9_16_salient_point_viz_frames.mp4


GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_2.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_2_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_2.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_2_9_16.mp4,aspect_ratio=9:16
---------
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_3.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_3_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/highlight_3.mp4,output_video_path=/opt/sportmultimedia/outputs/output/local_highlight_3_9_16.mp4,aspect_ratio=9:16


Issues:
https://github.com/google/mediapipe/issues/505

"E20221121 18:02:29.121098 11018 simple_run_graph_main.cc:149] Failed to run the graph: CalculatorGraph::Run() failed in Run: 
Calculator::Open() for node "OpenCvVideoDecoderCalculator" failed: ; OpenCVVideoDecoderCalculator can't save the audio file because FFmpeg is not installed. Please remove output_side_packet: "SAVED_AUDIO_PATH" from the node config."
$ sudo apt-get install libfdk-aac-dev
$ sudo apt-get install libopus-dev
$ sudo pip install ffmpeg-python



Method #2: Docker
=================

- https://google.github.io/mediapipe/getting_started/install.html#installing-using-docker
- https://github.com/google/mediapipe/issues/505


https://github.com/googleinterns/intern-for-design/tree/master/autoflip_integrated_calculators

Install Mediapipe
https://google.github.io/mediapipe/getting_started/install.html#installing-using-docker
https://github.com/google/mediapipe/issues/505


docker stop mediapipe ; docker rm mediapipe ; docker rmi mediapipe

$ git clone https://github.com/google/mediapipe.git
$ cd mediapipe
-> Fix Audio (see Error #2 below)
-> Get Models (see Error #3 below)
-> Change Dockerfile (see file below)

$ docker build --tag=mediapipe .
$ docker run -it -v /tmp/mediapipe:/home --name mediapipe mediapipe:latest (or, without bind folder: $ docker run -it --name mediapipe mediapipe:latest)
$ docker run -dt -v /opt/sportmultimedia/outputs:/home --name mediapipe mediapipe:latest

$ docker start `docker ps -q -l`
$ docker start `docker ps -q -l` && docker attach `docker ps -q -l`
$ docker exec -it mediapipe bash

Test image:
$ GLOG_logtostderr=1 bazel run --define MEDIAPIPE_DISABLE_GPU=1 mediapipe/examples/desktop/hello_world

- Build Autoflip
$ GLOG_logtostderr=1 bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 --copt -I/usr/include/opencv4/ mediapipe/examples/desktop/autoflip:run_autoflip

- Running Autoflip
$ GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/home/life_at_google.mp4,output_video_path=/home/output/life_at_google__1_1.mp4,aspect_ratio=1:1
---------
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/home/highlight_1.mp4,output_video_path=/home/output/highlight_1_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/home/highlight_1.mp4,output_video_path=/home/output/highlight_1_9_16.mp4,aspect_ratio=9:16
---------
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/home/highlight_2.mp4,output_video_path=/home/output/highlight_2_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/home/highlight_2.mp4,output_video_path=/home/output/highlight_2_9_16.mp4,aspect_ratio=9:16
---------
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/home/highlight_3.mp4,output_video_path=/home/output/highlight_3_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/home/highlight_3.mp4,output_video_path=/home/output/highlight_3_9_16.mp4,aspect_ratio=9:16


### Dockerfile
# Copyright 2019 The MediaPipe Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:20.04

MAINTAINER <mediapipe@google.com>

WORKDIR /io
WORKDIR /mediapipe

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc-8 g++-8 \
        ca-certificates \
        curl \
        ffmpeg \
        git \
		joe \
        wget \
        unzip \
        nodejs \
        npm \
        python3-dev \
        python3-opencv \
        python3-pip \
        libopencv-core-dev \
        libopencv-highgui-dev \
        libopencv-imgproc-dev \
        libopencv-video-dev \
        libopencv-calib3d-dev \
        libopencv-features2d-dev \
        libopencv-contrib-dev \
        software-properties-common \
		util-linux && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && apt-get install -y openjdk-8-jdk && \
    apt-get install -y mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev && \
    apt-get install -y mesa-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 --slave /usr/bin/g++ g++ /usr/bin/g++-8
RUN pip3 install --upgrade setuptools
RUN pip3 install wheel
RUN pip3 install future
RUN pip3 install absl-py numpy opencv-contrib-python protobuf==3.20.1
RUN pip3 install six==1.14.0
RUN pip3 install tensorflow
RUN pip3 install tf_slim
RUN pip3 install ffmpeg-python

RUN ln -s /usr/bin/python3 /usr/bin/python

# Install bazel
ARG BAZEL_VERSION=5.2.0
RUN mkdir /bazel && \
    wget --no-check-certificate -O /bazel/installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/b\
azel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    wget --no-check-certificate -O  /bazel/LICENSE.txt "https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE" && \
    chmod +x /bazel/installer.sh && \
    /bazel/installer.sh  && \
    rm -f /bazel/installer.sh

COPY . /mediapipe/

RUN bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 --copt -I/usr/include/opencv4/ mediapipe/examples/desktop/autoflip:run_autoflip

# If we want the docker image to contain the pre-built object_detection_offline_demo binary, do the following
# RUN bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 mediapipe/examples/desktop/demo:object_detection_tensorflow_demo

### Error #1

Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging
In file included from mediapipe/calculators/video/opencv_video_encoder_calculator.cc:30:
./mediapipe/framework/port/opencv_video_inc.h:88:10: fatal error: opencv2/optflow.hpp: No such file or directory
 #include <opencv2/optflow.hpp>
          ^~~~~~~~~~~~~~~~~~~~~
compilation terminated.
Target //mediapipe/examples/desktop/autoflip:run_autoflip failed to build

-> install libopencv-contrib-dev library

### Error #2

Remove Audio: https://github.com/google/mediapipe/issues/505

diff --git a/mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt b/mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt
index 95af188..3efda84 100644
--- a/mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt
+++ b/mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt
@@ -8,7 +8,6 @@ node {
   input_side_packet: "INPUT_FILE_PATH:input_video_path"
   output_stream: "VIDEO:video_raw"
   output_stream: "VIDEO_PRESTREAM:video_header"
-  output_side_packet: "SAVED_AUDIO_PATH:audio_path"
 }

 # VIDEO_PREP: Scale the input video before feature extraction.
@@ -192,7 +191,6 @@ node {
   input_stream: "VIDEO:cropped_frames"
   input_stream: "VIDEO_PRESTREAM:output_frames_video_header"
   input_side_packet: "OUTPUT_FILE_PATH:output_video_path"
-  input_side_packet: "AUDIO_FILE_PATH:audio_path"
   options: {
     [mediapipe.OpenCvVideoEncoderCalculatorOptions.ext]: {
       codec: "avc1"

### Error #3

Calculator::Open() for node "autoflipobjectdetectionsubgraph__TfLiteInferenceCalculator" failed: ; Can't find file: mediapipe/models/ssdlite_object_detection.tflite

--> curl https://storage.googleapis.com/mediapipe-assets/ssdlite_object_detection.tflite -o mediapipe/models/ssdlite_object_detection.tflite

### Error #4

Calculator::Open() for node "autoflipobjectdetectionsubgraph__DetectionLabelIdToTextCalculator" failed: ; Can't find file: mediapipe/models/ssdlite_object_detection_labelmap.txt

--> curl https://storage.googleapis.com/mediapipe-assets/ssdlite_object_detection_labelmap.txt -o mediapipe/models/ssdlite_object_detection_labelmap.txt

---------------------------------------------------

Portimonense, Jogada, Yago Cariello aos 2'
2223_J15_SLBxPTM_min_02_1_1
2223_J15_SLBxPTM_min_02_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_02.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_02_1_1.mp4,aspect_ratio=1:1
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_02.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_02_9_16.mp4,aspect_ratio=9:16

SL Benfica, Penálti, Gonçalo Ramos aos 7'
2223_J15_SLBxPTM_min_07_1_1
2223_J15_SLBxPTM_min_07_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_07.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_07_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_07.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_07_9_16.mp4,aspect_ratio=9:16

GOLO! SL Benfica, João Mário aos 9', SL Benfica 1-0 Portimonense
2223_J15_SLBxPTM_min_09_1_1
2223_J15_SLBxPTM_min_09_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_09.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_09_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_09.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_09_9_16.mp4,aspect_ratio=9:16

SL Benfica, Penálti, Alexander Bah aos 17'
2223_J15_SLBxPTM_min_17_1_1
2223_J15_SLBxPTM_min_17_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_17.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_17_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_17.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_17_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, António Silva aos 19'
2223_J15_SLBxPTM_min_19_1_1_1
2223_J15_SLBxPTM_min_19_1_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_19_1.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_19_1_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_19_1.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_19_1_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, Aursnes aos 19'                                  -- Penálti falhado
2223_J15_SLBxPTM_min_19_2_1_1
2223_J15_SLBxPTM_min_19_2_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_19_2.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_19_2_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_19_2.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_19_2_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, João Mário aos 26'
2223_J15_SLBxPTM_min_26_1_1
2223_J15_SLBxPTM_min_26_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_26.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_26_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_26.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_26_9_16.mp4,aspect_ratio=9:16

Portimonense, Caso, Filipe Relvas aos 41'
2223_J15_SLBxPTM_min_41_1_1
2223_J15_SLBxPTM_min_41_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_41.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_41_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_41.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_41_9_16.mp4,aspect_ratio=9:16


SL Benfica, Jogada, Florentino Luís aos 45'
2223_J15_SLBxPTM_min_45_1_1
2223_J15_SLBxPTM_min_45_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_45.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_45_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_45.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_45_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, Grimaldo aos 48'
2223_J15_SLBxPTM_min_48_1_1
2223_J15_SLBxPTM_min_48_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_48.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_48_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_48.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_48_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, Gonçalo Ramos aos 60'
2223_J15_SLBxPTM_min_60_1_1
2223_J15_SLBxPTM_min_60_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_60.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_60_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_60.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_60_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, Gonçalo Ramos aos 68'
2223_J15_SLBxPTM_min_68_1_1
2223_J15_SLBxPTM_min_68_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_68.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_68_1_1.mp4,aspect_ratio=1:1 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_68.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_68_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, Gonçalo Ramos aos 73'
2223_J15_SLBxPTM_min_73_1_1
2223_J15_SLBxPTM_min_73_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_73.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_73_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_73.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_73_9_16.mp4,aspect_ratio=9:16

Portimonense, Jogada, Yago Cariello aos 74'
2223_J15_SLBxPTM_min_74_1_1
2223_J15_SLBxPTM_min_74_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_74.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_74_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_74.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_74_9_16.mp4,aspect_ratio=9:16

SL Benfica, Jogada, João Neves aos 90'+3'
2223_J15_SLBxPTM_min_93_1_1
2223_J15_SLBxPTM_min_93_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_93.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_93_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/SLBxPTM/min_93.mp4,output_video_path=/opt/sportmultimedia/outputs/SLBxPTM/mediapipe/min_93_9_16.mp4,aspect_ratio=9:16

##########################################

Liga Portugal bwin (15ªJ): Resumo SL Benfica 1-0 Portimonense
2223_J15_Resumo_SLBxPTM_1_1
2223_J15_Resumo_SLBxPTM_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/SLBxPTM.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/SLBxPTM_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/SLBxPTM.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/SLBxPTM_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo Santa Clara 0-4 SC Braga
2223_J15_Resumo_STAxBRA_1_1
2223_J15_Resumo_STAxBRA_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/STAxBRA.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/STAxBRA_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/STAxBRA.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/STAxBRA_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo FC Famalicão 2-1 FC Vizela
2223_J15_Resumo_FAMxVIZ_1_1
2223_J15_Resumo_FAMxVIZ_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/FAMxVIZ.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/FAMxVIZ_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/FAMxVIZ.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/FAMxVIZ_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo FC Arouca 2-0 Estoril Praia
2223_J15_Resumo_AROxEST_1_1
2223_J15_Resumo_AROxEST_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/AROxEST.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/AROxEST_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/AROxEST.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/AROxEST_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo Vitória SC 0-0 Rio Ave FC
2223_J15_Resumo_VSCxRAV_1_1
2223_J15_Resumo_VSCxRAV_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/VSCxRAV.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/VSCxRAV_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/VSCxRAV.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/VSCxRAV_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo Casa Pia AC 0-0 FC Porto
2223_J15_Resumo_CPIxPOR_1_1
2223_J15_Resumo_CPIxPOR_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/CPIxPOR.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/CPIxPOR_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/CPIxPOR.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/CPIxPOR_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo FC P.Ferreira 1-1 GD Chaves
2223_J15_Resumo_PFExCHA_1_1
2223_J15_Resumo_PFExCHA_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/PFExCHA.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/PFExCHA_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/PFExCHA.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/PFExCHA_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo Marítimo M. 1-0 Sporting CP
2223_J15_Resumo_MARxSPO_1_1
2223_J15_Resumo_MARxSPO_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/MARxSPO.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/MARxSPO_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/MARxSPO.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/MARxSPO_9_16.mp4,aspect_ratio=9:16

Liga Portugal bwin (15ªJ): Resumo Boavista FC 1-0 Gil Vicente FC
2223_J15_Resumo_BOAxGIL_1_1
2223_J15_Resumo_BOAxGIL_9_16
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/BOAxGIL.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/BOAxGIL_1_1.mp4,aspect_ratio=1:1 && sleep 3 &&
GLOG_logtostderr=1 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt --input_side_packets=input_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/BOAxGIL.mp4,output_video_path=/opt/sportmultimedia/outputs/Jornada15_Resumos/mediapipe/BOAxGIL_9_16.mp4,aspect_ratio=9:16



---------------------------------------------------

How To
======

You can start by doing:
::
    
    cd /opt/sportmultimedia/Repo/video-platform
    npm run develop

Output:

::

    video-platform@0.1.0 build /opt/sportmultimedia/Repo/video-platform
    strapi build "--no-optimization"

In a browser, http://localhost:1337/admin

Commands
========

Start Strapi in watch mode

::

    npm run develop

Start Strapi without watch mode

::

    npm run start

Build Strapi admin panel

::

    npm run build

Display all available commands

::

    npm run strapi
