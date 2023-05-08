FROM python:3.7
ARG master_ip

RUN mkdir /publisher
WORKDIR /publisher
ADD . /publisher/
ENV MASTER_IP=$master_ip
RUN pip install paho-mqtt


EXPOSE 5000
CMD ["python3", "/publisher/publisher.py"]