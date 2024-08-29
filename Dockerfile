# Use the official Python image as a base
FROM python:3.11-buster


# Set environment variables for Spark and Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV SPARK_VERSION=3.5.2
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/home/spark
ENV PATH=$SPARK_HOME/bin:$PATH
ENV JAVA_VERSION=11

# Install necessary packages and dependencies
RUN apt-get update && apt-get install -y \
    "openjdk-${JAVA_VERSION}-jre-headless" \
    curl \
    wget \
    vim \
    sudo \
    whois \
    ca-certificates-java \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN java --version

## Download and install Apache Spark
#RUN DOWNLOAD_URL_SPARK="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"  \
#    && wget --verbose  -O apache-spark.tgz "${DOWNLOAD_URL_SPARK}" \
#    && mkdir -p /home/spark \
#    && tar -xf apache-spark.tgz -C /home/spark --strip-components=1 \
#    && rm apache-spark.tgz

# Use local downloaded jar/tarball into the image if you don't want to download from internet
COPY downloads/spark-3.5.2-bin-hadoop3.tgz apache-spark.tgz

# Create the directory, extract the tarball, and remove the tarball
RUN mkdir -p /home/spark \
    &&  mkdir -p /home/spark/logs \
    && tar -xf apache-spark.tgz -C /home/spark --strip-components=1 \
    && rm apache-spark.tgz

# Set environment variables for Python and Pyspark
ENV PIPENV_VENV_IN_PROJECT=1
ENV PYSPARK_PYTHON=/usr/local/bin/python3
ENV PYSPARK_DRIVER_PYTHON='jupyter'
ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook --no-browser --port=4041'


# Set up a non-root user
ARG USERNAME=sparkuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && chown $USER_UID:$USER_GID /home/$USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set ownership for Spark directories
RUN chown -R $USER_UID:$USER_GID /home/spark

# Set up Spark configuration for logging and history server
RUN echo "spark.eventLog.enabled true" >> $SPARK_HOME/conf/spark-defaults.conf \
    && echo "spark.eventLog.dir file:///home/${USERNAME}/app/event_logs" >> $SPARK_HOME/conf/spark-defaults.conf \
    && echo "spark.history.fs.logDirectory file:///home/${USERNAME}/app/logs" >> $SPARK_HOME/conf/spark-defaults.conf

# Install Python packages for Jupyter and PySpark
RUN pip install --no-cache-dir jupyter findspark

# Add the entrypoint script
COPY entrypoint.sh /home/spark/entrypoint.sh
RUN chmod +x /home/spark/entrypoint.sh

# Switch to non-root user
USER $USERNAME

# Create directories for the user and set workdir
RUN mkdir -p /home/$USERNAME/app \
    && mkdir -p /home/$USERNAME/app/event_logs \
    && mkdir -p /home/$USERNAME/app/logs

RUN ls -ltr /home/spark/logs

WORKDIR /home/$USERNAME/app

# Expose necessary ports for Jupyter and Spark UI
EXPOSE 4040 4041 18080 8888

ENTRYPOINT ["/home/spark/entrypoint.sh"]