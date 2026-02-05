import time
import os
import boto3
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# configuration
BUCKET_NAME = "ares-telemetry-storage-raafaysiddiqui"
# The folder where json incidentsvare saved
WATCH_DIRECTORY = "./Backend/logs/engineering_review"
# ---------------------

s3_client = boto3.client('s3')


class ARESHandler(FileSystemEventHandler):
    def on_created(self, event):
        # new files, not folders
        if not event.is_directory and event.src_path.endswith(".json"):
            filename = os.path.basename(event.src_path)
            print(f"New incident detected: {filename}")

            try:
                # upload to S3
                s3_client.upload_file(event.src_path, BUCKET_NAME, filename)
                print(f"Successfully synced {filename} to S3.")
            except Exception as e:
                print(f"Failed to upload {filename}: {e}")


if __name__ == "__main__":
    # create the watch folder if it doesn't exist
    if not os.path.exists(WATCH_DIRECTORY):
        os.makedirs(WATCH_DIRECTORY)

    event_handler = ARESHandler()
    observer = Observer()
    observer.schedule(event_handler, WATCH_DIRECTORY, recursive=False)

    print(f"ARES Scout is watching: {WATCH_DIRECTORY}")
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        print("\nStopping Scout...")
    observer.join()
