
#
# CUDA enabled OpenCV 4.1.1
#
FROM nvcr.io/nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /src

ENV TZ 'Europe/Berlin' 
ENV OPENCV_VERSION '4.1.1'
RUN apt-get update && apt-get install -y -qq --no-install-recommends apt-utils
# RUN echo $TZ > /etc/timezone && \
#   apt-get install -y tzdata && \
#   rm /etc/localtime && \
#   ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
#   dpkg-reconfigure -f noninteractive tzdata && \
#   apt-get clean
  
RUN apt-get update && apt-get upgrade -qq -y
RUN apt-get install software-properties-common zsh -qq -y
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && apt-get update
RUN apt-get install -qq -y apt-utils build-essential git unzip wget libssl-dev curl qt5-default libvtk6-dev \
            zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libjasper-dev \
            libopenexr-dev libgdal-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev \
            libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm \
            libopencore-amrnb-dev libopencore-amrwb-dev libv4l-dev libxine2-dev \
            libtbb-dev libeigen3-dev python-dev  python-tk  pylint  python-numpy  \
            python3-dev python3-tk pylint3 python3-numpy flake8 doxygen \
            cmake clang-9 \
            && ln -s /usr/include/eigen3/Eigen /usr/include/Eigen
#RUN git clone -b v3.17.2 https://github.com/Kitware/CMake.git cmake-3.17.2; cd cmake-3.17.2; ./bootstrap && make -j8 && make install; cd .. && rm -rf cmake-3.17.2
#RUN apt-get install cmake clang-9 -qq -y

RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
            unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip && \
            mv opencv-${OPENCV_VERSION} OpenCV && \ 
        wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
            unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip && \
            mv opencv_contrib-${OPENCV_VERSION} opencv_contrib

WORKDIR /src/OpenCV/build
#RUN ln -s /usr/include/eigen3 /usr/include/eigen

RUN  cmake .. -DCMAKE_BUILD_TYPE=RELEASE \
       -DENABLE_PRECOMPILED_HEADERS=ON \
       -DCMAKE_INSTALL_PREFIX=/usr/local \
       -DWITH_GSTREAMER=ON \
       -DOPENCV_ENABLE_NONFREE=ON \
       -DBUILD_TESTS=OFF \
       -DBUILD_PERF_TESTS=OFF \
       -DINSTALL_C_EXAMPLES=OFF \
       -DINSTALL_PYTHON_EXAMPLES=OFF \
       -DPYTHON_EXECUTABLE=/usr/bin/python3 \
       -DBUILD_opencv_python2=OFF \
       -DPYTHON3_EXECUTABLE=/usr/bin/python3 \
       -DPYTHON3_INCLUDE_DIR=/usr/include/python3.6m \
       -DPYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
       -DWITH_TBB=ON \
       -DWITH_V4L=ON \
       -DWITH_QT=ON \
       -DWITH_OPENGL=ON \
       -DWITH_CUDA=ON \
       -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs \
       -DWITH_NVCUVID=OFF \
       -DWITH_CUDNN=ON \
       -DCUDA_HOST_COMPILER=/usr/bin/gcc \
       -DOPENCV_DNN_CUDA=ON \
       -DENABLE_FAST_MATH=1 \
       -DCUDA_FAST_MATH=1 \
       -DCUDA_ARCH_BIN=7.5 \
       -DWITH_CUBLAS=1 \
       -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
       -DBUILD_EXAMPLES=OFF \
       -DOPENCV_GENERATE_PKGCONFIG=YES \
       && make -j8 && make install

#RUN make -j8 && make install && rm -rf /src/OpenCV


# -m option creates a fake writable home folder for Jupyter.
#RUN groupadd -g 1000 justin && \
#    useradd -m -r -u 1000 -g justin justin
#USER justin

#VOLUME ["/src"]
WORKDIR /src
RUN rm -rf /src/OpenCV && rm -rf /src/opencv_contrib



#CMD ["jupyter", "notebook", "--no-browser", "--ip=0.0.0.0", \
#     "/src/deep-learning-with-python-notebooks"]