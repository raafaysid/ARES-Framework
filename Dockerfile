# start with a lightweight Python image
FROM python:3.9-slim

# set the working directory inside the container
WORKDIR /app
#ensuring the logs and review folders exist and have correct permissions
RUN mkdir -p /app/logs/engineering_review && chmod -R 777 /app/logs
# copy the local files into the container
COPY Backend/ /app/Backend/
COPY ios-app/Ares_framework/flight_data.json /app/flight_data.json

# install any dependencies
#copy requirements and install
COPY Backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

#expose the port for server
EXPOSE 8000

# run the telemetry generator when the container starts
CMD ["python", "Backend/telemetry_gen.py"]