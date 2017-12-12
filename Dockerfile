# Get environment variables, default is the author's username
# Need docker >= 17.0.5 in order to accept ARG before FROM
ARG DOCKER_ORGANIZATION=doanminhdang

# Pull base image with casadi precompiled
FROM $DOCKER_ORGANIZATION/rpi-debian-casadi:latest

# Define working directory
WORKDIR /home/pi

# Display previous time when swig was installed
RUN DATE_FILE=date_install_casadi.txt && \
    if [ -f $DATE_FILE ]; then echo "swig compiled:" && cat $DATE_FILE; fi

# Display previous time when casadi was installed
RUN DATE_FILE=date_install_casadi.txt && \
    if [ -f $DATE_FILE ]; then echo "casadi compiled:" && cat $DATE_FILE; fi

# Update acados source code, already cloned when compiling swig
RUN cd acados && git pull origin master && git submodule update --recursive --init

# Compile acados with Python interface
# Note that supporting packages were installed when compiling swig
RUN cd /home/pi/acados && \
    rm -rf build && mkdir build && \
    cd build && \
    cmake -D SWIG_MATLAB=0 -D SWIG_PYTHON=1 .. && \
    make install

# Set environment variables for acados lib, note that user is root
ENV PYTHONPATH="${PYTHONPATH}:${HOME}/local/lib"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib:$HOME/local/lib"

# Test
RUN cd /home/pi/acados/examples/python && \
    python3 -c "import acados"

# Add date for tracing the date of installing
RUN cd /home/pi && date -u '+%F %T %Z' > date_install_acados.txt

# Define default command
CMD ["bash"]
